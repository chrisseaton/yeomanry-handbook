#!/usr/bin/env ruby

people_groups = [[nil, []]]

ARGF.each_line do |line|
  case line
  when "\n"
    people_groups.push [nil, []] unless people_groups.last.last.empty?
  when /^#+\s+(.*)$/
    people_groups.pop if people_groups.last.first.nil? && people_groups.last.last.empty?
    people_groups.push [$1, []]
  when /^\* (.*:\s+)?(.*)$/
    appointment = $1
    next if appointment == "Tp Ldrs:\n"
    name = $2
    name.gsub! /\b(\d+)st\b/, '\1\st'
    name.gsub! /\b(\d+)nd\b/, '\1\nd'
    name.gsub! /\b(\d+)rd\b/, '\1\rd'
    name.gsub! /\b(\d+)th\b/, '\1\nth'
    appointment.sub! /:\s+$/, '' if appointment
    people_groups.last.last.push [appointment, name]
  when /^  \* (.*)$/
    appointment = 'Tp Ldr'
    name = $1
    name.gsub! /\b(\d+)st\b/, '\1\st'
    name.gsub! /\b(\d+)nd\b/, '\1\nd'
    name.gsub! /\b(\d+)rd\b/, '\1\rd'
    name.gsub! /\b(\d+)th\b/, '\1\nth'
    appointment.sub! /:\s+$/, '' if appointment
    people_groups.last.last.push [appointment, name]
  end
end

clear_tp_ldrs = false

people_groups.each_with_index do |(title, people), n|
  if people.all? { |a, _| a.nil? }
    if n > 0 && people_groups[n - 1].last.all? { |a, _| a.nil? }
      puts '  \\\\' 
      puts "  \\textbf{#{title}} \\\\"
    else
      if title
        puts '\begin{center}'
        puts '  \Large'
        puts "  \\textbf{#{title}}"
        puts '\end{center}'
        puts
      end

      puts '\begin{multicols}{2}'
      puts '  \noindent'
    end

    people.each do |_, name|
      puts "  #{name} \\\\"
    end
    
    unless n < people_groups.size - 1 && people_groups[n + 1].last.all? { |a, _| a.nil? }
      puts '\end{multicols}'
      puts
    end
  else
    if n > 0 && n < people_groups.size - 1 && people_groups[n + 1].last.all? { |a, _| a.nil? }
      puts '\end{multicols}'
      puts
    end

    if title
      puts '\begin{center}'
      puts '  \Large'
      puts "  \\textbf{#{title}}"
      puts '\end{center}'
      puts
    end

    puts '\begin{center}'
    puts '  \begin{tabular}{rl}'
    people.each do |appointment, name|
      if appointment
        if appointment == 'Tp Ldr'
          if clear_tp_ldrs
            appointment = nil
          else
            appointment = 'Tp Ldrs'
            clear_tp_ldrs = true
          end
        else
          clear_tp_ldrs = false
        end
        puts "    #{appointment} & #{name} \\\\"
      else
        puts "    & #{name} \\\\"
      end
    end
    puts '  \end{tabular}'
    puts '\end{center}'
    puts
  end
end
