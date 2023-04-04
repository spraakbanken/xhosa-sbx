f = File.open("sadilar.txt","r:utf-8")
counter = 0
clean_segms = []
f.each_line do |line|
    line1 = line.strip
    if !line1.include?("<LINE#") and !line1.include?("[Punc]")
        line2 = line1.split("\t")
        word = line2[0].downcase
        #STDERR.puts word
        morphemes0 = line2[1].downcase
        #STDERR.puts morphemes0
        morphemes = []
        morpheme = ""
        flag = true
        morphemes0.each_char do |symbol|
            if symbol == "["
                morphemes << morpheme
                flag = false
                morpheme = ""
            end
            if flag
                morpheme << symbol
            end

            if symbol == "-"
                flag = true
            end
        end
        #STDERR.puts morphemes
        if word == morphemes.join("")
            counter += 1
            #STDOUT.puts word
            clean_segms << morphemes
        end

    end

end

#STDERR.puts counter
o = File.open("sadilar_train.tsv","w:utf-8")
clean_segms.each do |segm|
    o.puts "*\tO"
    segm.each do |morpheme|
        morpheme.each_char.with_index do |symbol,index|
            if index == 0
                o.puts "#{symbol}\tB"
            else
                o.puts "#{symbol}\tI"
            end
        end
        
    end
end
o.puts "*\tO"