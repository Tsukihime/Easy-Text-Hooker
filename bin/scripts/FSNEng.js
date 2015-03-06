/* Fate/Stay Night English version */
/* Script encoding - UTF-8 */
function myTrim(str)
{
    return str.replace(/^\s+|\s+$/gm,'');
}

function FixWord(word)
{
    word = word.replace('Fuji- Nee', 'Фуджи')
        .replace('Fuji--Nee', 'Фуджи')
        .replace('Fuji-Nee', 'Фуджи')
        .replace('Taiga', 'Тигра')
        .replace('stopping', 'останавливать')
        .replace('Man', 'Хм')
        .replace('Emiya', 'Эмия')
        .replace('Shirou', 'Широ')
        .replace('Rin', 'Рин')
        .replace('Tohsaka', 'Тосака')
        .replace('Archer', 'Арчер')
        .replace('Lancer', 'Лансер')
        .replace('Saber', 'Сейбер')
        .replace('Rider', 'Райдер')
        .replace('Caster', 'Кастер')
        .replace('Assassin', 'Ассасин')
        .replace('Berserker', 'Берсеркер')
        .replace('Iliya', 'Илия')
        .replace('Ilyasviel', 'Илиясфиль')
        .replace('Ilya', 'Илия')
        .replace("Servant's", 'Слуги')
        .replace('Servants', 'Слуги')
        .replace('Servant', 'Слуга')
        .replace('spirits', 'духи')
        .replace('spirit', 'дух')
        .replace('Kirei', 'Кирей')
        .replace('Kotomine', 'Котомине')
        .replace('magus', 'маг')
        .replace('mana', 'мана')
        .replace('powerful', 'сильный')
        .replace('powers', 'силы')
        .replace('power', 'сила')
        .replace('Shinji', 'Синдзи')
        .replace('Einzbern', 'Айнцберн')
        .replace('Makiri', 'Макири')
        .replace('Matou', 'Мато')
        .replace('Bug', 'Жук')
        .replace('bug', 'жук')
        .replace('Zouken', 'Зокен')
        .replace('Kiritsugu', 'Кирицугу')
        .replace('Phantasm', 'Фантазм');

    return word;
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

            // hellohdworld == hello\nworld
            if ((p > 1) && (len > 3) && (p < len - 2)) {
                word = word.substr(1, p) + ' ' + word.substr(p + 2);
            }

            // gcontradicting-yourself?"
            // oto-death"?
            var minus = word.indexOf('-');
            if((minus > 1) && (word.charAt(0) == word.charAt(minus - 1)))
            {
                word = word.substr(1, minus - 1) + word.substr(minus);
            }

            // arMaster  == a\nMaster
            var chrend = word.charAt(word.length - 1);
            if ((word.length > 2) && (word.charAt(1) == chrend) &&
                (word.charAt(2) == word.charAt(2).toLocaleUpperCase()))
            {
                word = word.charAt(0) + ' ' + word.substr(2);
            }

            // ywhyI == why\nI
            if ((word.length > 2) && (word.charAt(0) == word.charAt(word.length - 2)) &&
                (chrend == chrend.toLocaleUpperCase()))
            {
                word = word.substr(1, word.length - 2) + ' ' + chrend;
            }

            // ohello == hello
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
        sentence = sentence + FixWord(wordlist[i]) + ' ';
    }

    return sentence;
}