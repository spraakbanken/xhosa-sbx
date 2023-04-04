add = "own"

STDERR.puts "Training..."
system "java -Xmx5G -cp marmot.jar marmot.morph.cmd.Trainer -train-file form-index=0,tag-index=1,#{add}_train.tsv -tag-morph false -model-file segm_#{add}.marmot"

STDERR.puts "Tagging..."
system "java -Xmx5G -cp marmot.jar marmot.morph.cmd.Annotator -test-file form-index=0,test_segm.tsv -tag-morph false -model-file segm_#{add}.marmot -pred-file pred_segm_#{add}.tsv"

STDERR.puts "Evaluating and printing..."



f2 = File.open("test_segm.tsv","r:utf-8")
gold_bios = []
f2.each_line.with_index do |line,index|
    line2 = line.strip.split("\t")
    gold_bios << line2[1]
end
f2.close


f = File.open("pred_segm_#{add}.tsv","r:utf-8")
@o = File.open("merged_segm_#{add}.tsv","w:utf-8")
@o.puts "auto\tgold"
gold_word = nil
auto_word = nil
gold_morph = ""
auto_morph = ""
exact_word = 0.0
total_word = 0.0
bulls = 0.0
cows = 0.0
total_morphemes = 0.0

def find_bulls(auto_word,gold_word)
    bulls = 0
    l = [gold_word.length,auto_word.length].min - 1
    for i in 0..l do
        if gold_word[i] == auto_word[i]
            bulls += 1
        end
    end
    return bulls
end

def print_morphs(auto_word,gold_word)
    #bulls = 0
    l = [gold_word.length,auto_word.length].max - 1
    for i in 0..l do
        @o.puts "#{auto_word[i]}\t#{gold_word[i]}"
    end
end

f.each_line.with_index do |line,index|
    #if index > 0
        line2 = line.strip.split("\t")
        symbol = line2[1]
        auto_bio = line2[5]
        #gold_bio = line2[8]
        gold_bio = gold_bios[index]
        #STDERR.puts "#{symbol} #{auto_bio} #{gold_bio}"
        if symbol == "*"
            if auto_morph != ""
                auto_word << auto_morph
            end
            if gold_morph != ""
                gold_word << gold_morph
            end
            if !gold_word.nil?
                total_word += 1
                #STDERR.puts total_word
                #STDERR.puts "#{auto_word}, #{gold_word}"
                total_morphemes += [gold_word.length,auto_word.length].max
                #STDERR.puts total_morphemes
                if gold_word == auto_word
                    exact_word += 1
                end
                bulls += find_bulls(auto_word,gold_word)
                print_morphs(auto_word,gold_word)
                @o.puts ""
            end
            gold_word = []
            auto_word = []
            gold_morph = ""
            auto_morph = ""
            #STDERR.puts "#{auto_word}, #{gold_word}"
        else
            
            if auto_bio == "B"
                
                if auto_morph != ""
                    auto_word << auto_morph
                end
                auto_morph = symbol.clone
            elsif auto_bio == "I"
                auto_morph << symbol
            end
            if gold_bio == "B"
                if gold_morph != ""
                    gold_word << gold_morph
                end
                gold_morph = symbol.clone
            elsif gold_bio == "I"
                gold_morph << symbol
            end
    
        end
        #STDERR.puts "#{symbol} #{auto_bio} #{gold_bio}"
        #STDERR.puts "auto: #{auto_morph}"
        #STDERR.puts "gold: #{gold_morph}"
    #end
    
end

STDERR.puts exact_word/total_word
STDERR.puts bulls/total_morphemes