public with sharing class PseudoWordsUtil {
    
    public static String pseudoKeyGenerator(String record) {

        String result = '';
        List<String> process = new List<String>();
        
        if(record.contains(' ')){
            process = record.split(' ');
        }else{
            process.add(record);
        }

        for(String word : process){
            
            String firstLetter;
            String lastLetter;
            List<String> characters = word.split('');

            if(word.length() == 1 || word.length() == 2 || word.length() == 3){
                result += word + ' ';
            }else{
                firstLetter = characters[0];
                lastLetter = characters[word.length() - 1];
                characters.remove(0);
                characters.remove(characters.size() - 1);
                String shuffledWord = shuffleWords(characters);
                result += firstLetter + shuffledWord + lastLetter + ' ';
            }
        }
        
            return result.removeEnd(' ');
    }

    public static String shuffleWords(List<String> words){

        if (words.isEmpty()) return ''; 

        String result = '';
        while(words.size() > 0){
            Integer index = Math.mod(Math.abs(Crypto.getRandomInteger()), words.size());
            result += words[index];
            words.remove(index);    
        }
        return result;
    }
}