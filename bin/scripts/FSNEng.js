/* Fate/Stay Night English version */
/* Encoding - UTF-8*/
function myTrim(str)
{
    return str.replace(/^\s+|\s+$/gm,'');
}

/* preprocess text function */
function process_text(text) {
    var sentence = ' ' + text + ' ';
    var wordlist = [];
    var i = 0;
    var word = '';

    // explode str
    while (i <= sentence.length) {
        if (sentence.charAt(i) == " ") {
            word = myTrim(word);
            if (word.length > 0) {
                wordlist.push(word);
                word = '';
            }
        } else
            word = word + sentence.charAt(i);
        i++;
    }

    for (i = 0; i < wordlist.length; i++) {
        word = wordlist[i];
        var len = word.length;

        if (len > 1) {
            var tmp = word.charAt(0) + word.charAt(len - 1);
            var t2 = word.substr(1);
            var p = t2.indexOf(tmp) + 1;

            if ((p > 1) && (len > 3) && (p < len - 2)) {
                word = word.substr(1, p) + ' ' + word.substr(p + 2);
            }

            if (word.charAt(0) == word.charAt(len - 1)) {
                word = word.substr(1);
            }

            if ((word.charAt(len - 1) == '"') && (word.charAt(0) == '-'))
                word = word.substr(1);
        }

        wordlist[i] = word;
    }

    // implode str
    sentence = '';
    for (i = 0; i < wordlist.length; i++) {
        sentence = sentence + wordlist[i] + ' ';
    }

    sentence = sentence.replace('Fuji- Nee', 'Фуджи')
        .replace('Fuji--Nee', 'Фуджи')
        .replace('Fuji-Nee', 'Фуджи')
        .replace('Man', 'бля')
        .replace('Emiya', 'Эмия')
        .replace('Shirou', 'Широ')
        .replace('Rin', 'Рин')
        .replace('Tohsaka', 'Тосака')
        .replace('Saber', 'Сейбер')
        .replace('Berserker', 'Берсеркер')
        .replace('Iliya', 'Илия')
        .replace('Servant', 'Слуга')
        .replace('Kirei', 'Кирей')
        .replace('Kiritsugu', 'Кирицугу');

    return sentence;
}