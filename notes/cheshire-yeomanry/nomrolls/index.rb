#!/usr/bin/env ruby

def surname(name)
  name.sub! /\s*<!-- .* >/, '' # Remove any comment
  name.sub! /^.*: /, '' # Remove any appointment
  name.sub! /^(Lt Col|Pte|Dvr|SAC|Mr|Tpr|Sig|Spr|LCpl|Cpl|Sgt|CoH|SSgt|WO2|WO1|OCdt|2Lt|Lt|Capt|Maj|Col|Cnt|Cfn|Dvr\/Mec|Farr|Farr\/Sgt|Farr\/Cpl|Dvr\/IC|Farr\/SSgt|Tptr|Sgt\/Cook|Arm\/Sgt|Farr\/QMS|Cpl\/Tptr|Bandsman|Bugler|CSgt|LSgt|Rev|Dr|Mrs|Quartermaster|SCpl|WSIWSMI|WSSI|WSI|WSMI|Under Officer|Ensign|Shoeing Smith|SMI|Scpl|Sergeant Major|Sergeant Tptr|Maj Commandant)\s+/, '' # Remove any rank
  name.sub! /^Sir (\w+) /, '' # Remove Sir and first name
  name.sub! /^Lord (\w+) /, '' # Remove Lord and first name
  name.sub! /\s+\(.*\)$/, '' # Remove anything in brackets afterwards (QM, regiment, etc)
  name.sub! /, (Jnr|Snr)$/, '' # Remove any suffixes
  name.sub! /, .*$/, '' # Remove titles after a comma

  if name =~ /^([A-Z] )*([\w\-' ]+)$/ # Simple initials and surname
    name = $2
    name.sub! /^de[MV]? /, '' # Remove some prefixes
    name unless name.size == 1 # Ignore single letter names
  else
    puts "rejected #{name.inspect}"
    nil
  end
end

index = {}

Dir.glob('*.md', base: __dir__) do |file|
  next if ['1660.md', '1666.md'].include?(file) # Indexed separately

  case file
  when /(\d\d\d\d)(\-index)?\.md/
    year = Integer($1)

    File.open(File.join(__dir__, file), 'r') do |file|
      file.each_line do |line|
        case line
        when "* Tp Ldrs:\n"
          next
        when "* 2IC: Maj R W D Phillips-Brocklehurst, but officially Maj H R A Grosvenor, 2nd Duke of Westminster\n"
          (index['Phillips-Brocklehurst'] ||= []).push year
          (index['Grosvenor'] ||= []).push year
        when "* C Sqn Ldr: Maj R N H Verdin, soon replaced by Maj C W Tomkinson when Maj Verdin failed medical\n"
          (index['Verdin'] ||= []).push year
          (index['Tomkinson'] ||= []).push year
        when "* A (Tatton) Sqn Ldr: Capt M Egerton (in Kenya), then Maj Glazebrook when D Sqn split up, Capt Egerton worked in the Admiralty for rest of the War\n"
          (index['Egerton'] ||= []).push year
          (index['Glazebrook'] ||= []).push year
        when /^\s*\* (.*)$/
          key = surname($1)
          next unless key
          (index[key] ||= []).push year
        end
      end
    end
  when 'officers.md'
    File.open(File.join(__dir__, file), 'r') do |file|
      year = nil
      file.each_line do |line|
        line.sub! /\s*<!-- .* >/, '' # Remove any comment
        case line
        when /^## (\d\d\d\d)$/
          year = Integer($1)
        when /^\* (.*)$/
          key = surname($1)
          next unless key
          (index[key] ||= []).push year
        end
      end
    end
  end
end

File.open(File.join(__dir__, '../rolls-of-honour.md'), 'r') do |file|
  year = nil
  file.each_line do |line|
    case line
    when "## The Boer Wars\n"
      year = :boer_honour_roll
    when "## Pre-War\n"
      year = :pre_war_roll
    when "## First World War\n"
      year = :first_world_war_roll
    when "## Inter War\n"
      year = :inter_war_roll
    when "## Second World War\n"
      year = :second_world_war_roll
    when "## Post-War\n"
      year = :post_war_roll
    when "## Modern History\n"
      year = :modern_history_roll
    when /^\* (.*)$/
      key = surname($1)
      next unless key
      (index[key] ||= []).push year
    end
  end
end

[['hon-cols.md', :hon_cols], ['comd.md', :comd], ['sm.md', :sm]].each do |list, year|
  File.open(File.join(__dir__, "../#{list}"), 'r') do |file|
    file.each_line do |line|
      case line
      when "* (gapped due to KSLI?)\n"
      when /^\* (.*)$/
        key = surname($1)
        next unless key
        (index[key] ||= []).push year
      end
    end
  end
end

File.open(File.join(__dir__, 'see.txt'), 'r') do |file|
  file.each_line do |line|
    case line
    when /(.*), (.*)$/
      (index[$1] ||= []).push "see #{$2}"
    else
      raise
    end
  end
end

sorted_index = []

index.keys.sort.each do |name|
  input_years = index[name].uniq.sort_by(&:to_s)

  output_years = []
  input_years.each do |year|
    if output_years.empty?
      output_years.push year
    elsif output_years.last.is_a?(Integer) && year.is_a?(Integer) && output_years.last == year - 1
      output_years.pop
      output_years.push (year - 1 .. year)
    elsif output_years.last.is_a?(Range) && year.is_a?(Integer) && output_years.last.end == year - 1
      range = output_years.pop
      output_years.push (range.begin .. year)
    else
      output_years.push year
    end
  end

  sorted_index.push [name, output_years]
end

File.open(File.join(__dir__, 'index.md'), 'w') do |file|
  file.puts '## Index of Names'
  file.puts

  sorted_index.each do |name, years|
    file.puts "* #{name}, #{years}"
  end
end

File.open(File.join(__dir__, '../../../cheshire-yeomanry-handbook/nomrolls/index.tex'), 'w') do |file|
  file.puts '\renewcommand*{\indexname}{Index of Surnames}'
  file.puts '\begin{theindex}'

  sorted_index.each do |name, years|
    years.map! do |year|
      case year
      when :boer_honour_roll, :pre_war_roll, :first_world_war_roll,
          :inter_war_roll, :second_world_war_roll, :post_war_roll,
          :modern_history_roll
        'Rolls of Honour'
      when :hon_cols
        'Honorary Colonels'
      when :comd
        'Commanders'
      when :sm
        'Sergeants Major'
      else
        year
      end
    end

    years.uniq!

    file.puts "\\item #{name}, #{years.join(', ')}"
  end

  file.puts '\end{theindex}'
end
