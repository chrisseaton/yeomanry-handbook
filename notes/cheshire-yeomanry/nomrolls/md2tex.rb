#!/usr/bin/env ruby

officers = ARGV.delete('--officers')

people_groups = [[nil, []]]

ARGF.each_line do |line|
  case line
  when "\n"
    if people_groups.last.first.nil? && people_groups.last.last.empty?
      people_groups.pop
      people_groups.push [nil, []]
    end
  when /^##\s+(.*)$/
    people_groups.pop if people_groups.last.first.nil? && people_groups.last.last.empty?
    people_groups.push [$1, []]
  when /^\* (.*:\s+)?(.*)$/
    appointment = $1
    name = $2
    name.gsub! /\b(\d+)st\b/, '\1\st'
    name.gsub! /\b(\d+)nd\b/, '\1\nd'
    name.gsub! /\b(\d+)rd\b/, '\1\rd'
    name.gsub! /\b(\d+)th\b/, '\1\nth'
    appointment.sub! /:\s+$/, '' if appointment
    people_groups.last.last.push [appointment, name]
  end
end

if officers
  puts '\begin{multicols}{2}'
  puts '  \noindent'
  
  people_groups.each do |year, people|
    puts "  \\section*{#{year}}"
    people.each do |_, name|
      puts "  #{name} \\\\"
    end
  end
  
  puts '\end{multicols}'
  puts
else
  people_groups.each do |title, people|
    if title
      puts '\begin{center}'
      puts '  \Large'
      puts "  \\textbf{#{title}}"
      puts '\end{center}'
      puts
    end

    if people.all? { |appointment, name| appointment.nil? }
      puts '\begin{multicols}{2}'
      puts '  \noindent'
      people.each do |_, name|
        puts "  #{name} \\\\"
      end
      puts '\end{multicols}'
      puts
    else
      puts '\begin{center}'
      puts '  \begin{tabular}{rl}'
      people.each do |appointment, name|
        if appointment
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
end
