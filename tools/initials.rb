ARGF.each_line do |line|
  line.chomp!
  match = line.match(/^\* ([A-Za-z12]+) ([A-Za-z'\-]+)[\.,]? ([A-Z].?( [A-Z].?)*)( \(.*?\))?$/)
  if match
    if match[-1]&.start_with?(' ')
      puts "* #{match[1]} #{match.to_a[3]} #{match[2]}#{match[-1]}"
    else
      puts "* #{match[1]} #{match.to_a[3]} #{match[2]}"
    end
  else
    puts line
  end
end
