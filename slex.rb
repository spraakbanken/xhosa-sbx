f = File.open("#{ARGV[0]}.tsv","r:utf-8")
o = File.open("#{ARGV[0]}_slex.tsv","w:utf-8")
f.each_line do |line|
    line2 = line.strip.split("\t")
    if line2[1].include?("LEX")
        o.puts "#{line2[0]}\tLEX"
    else
        o.puts line2.join("\t")
    end

end