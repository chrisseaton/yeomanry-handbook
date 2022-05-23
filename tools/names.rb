ranks = {
  'Sgt.' => 'Sgt',
  'Sgt' => 'Sgt',
  'L/Sgt.' => 'LSgt',
  'Cpl.' => 'Cpl',
  'L/Cpl.' => 'LCpl',
  'L/Cpl' => 'LCpl',
  'Sgm.' => 'Sig',
  'Sgm' => 'Sig',
  'Dvr.' => 'Dvr',
  'Dvr/Mech' => 'Dvr/Mec',
  'Tpr.' => 'Tpr',
  'Dvr/I.C.' => 'Dvr/IC',
  'Lieut.' => 'Lt',
  'Pte.' => 'Pte',
  'Dr.' => 'Dr',
  'Tptr.' => 'Tptr',
  'Tptr' => 'Tptr',
  'Farr.' => 'Farr',
  'Farr' => 'Farr',
  'Captain' => 'Capt',
  'Major' => 'Maj'
}

previous_rank = nil

loop do
  line = gets
  break unless line

  # General tidy up
  line.tr!('„', '"')
  line.gsub!(/\s+/, ' ')
  line.gsub!(/[\*23§]/, '')
  line.strip!

  # Continued rank
  if line.start_with?('"')
    raise unless previous_rank
    line = previous_rank + ' ' + line.delete_prefix('"').strip
  elsif line.start_with?(',,')
    raise unless previous_rank
    line = previous_rank + ' ' + line.delete_prefix(',,').strip
  elsif line.start_with?('"')
    raise unless previous_rank
    line = previous_rank + ' ' + line.delete_prefix('"').strip
  end

  # Normalise ranks
  rank = ranks.keys.find { |rank| line.start_with?("#{rank} ") }
  if rank
    norm_rank = ranks[rank]
    previous_rank = rank
    line = norm_rank + ' ' + line.delete_prefix(rank).strip
  end

  # Move initials in front
  if line.match(/^(.*),\s*(([A-Z]\.?\s*)+),?$/)
    fore = $1
    initials = $2.split(/[\.?\s]/).map(&:strip).reject(&:empty?)
    rank = ranks.values.find { |rank| fore.start_with?("#{rank} ") }
    if rank
      line = rank + ' ' + initials.join(' ') + ' ' + fore.delete_prefix(rank).strip
    else
      line = initials.join(' ') + ' ' + fore.strip
    end
  end

  puts line
end
