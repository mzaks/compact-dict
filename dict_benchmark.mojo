import benchmark
from compact_dict import Dict
from collections.dict import KeyElement, Dict as StdDict
from pathlib import cwd
from testing import assert_equal

fn english_text_to_keys() raises -> DynamicVector[String]:
    return String('A wonderful serenity has taken possession of my entire soul, like these sweet mornings of spring which I enjoy with my whole heart. I am alone, and feel the charm of existence in this spot, which was created for the bliss of souls like mine. I am so happy, my dear friend, so absorbed in the exquisite sense of mere tranquil existence, that I neglect my talents. I should be incapable of drawing a single stroke at the present moment; and yet I feel that I never was a greater artist than now. When, while the lovely valley teems with vapour around me, and the meridian sun strikes the upper surface of the impenetrable foliage of my trees, and but a few stray gleams steal into the inner sanctuary, I throw myself down among the tall grass by the trickling stream; and, as I lie close to the earth, a thousand unknown plants are noticed by me: when I hear the buzz of the little world among the stalks, and grow familiar with the countless indescribable forms of the insects and flies, then I feel the presence of the Almighty, who formed us in his own image, and the breath of that universal love which bears and sustains us, as it floats around us in an eternity of bliss; and then, my friend, when darkness overspreads my eyes, and heaven and earth seem to dwell in my soul and absorb its power, like the form of a beloved mistress, then I often think with longing, Oh, would I could describe these conceptions, could impress upon paper all that is living so full and warm within me, that it might be the mirror of my soul, as my soul is the mirror of the infinite God! O my friend -- but it is too much for my strength -- I sink under the weight of the splendour of these visions! A wonderful serenity has taken possession of my entire soul, like these sweet mornings of spring which I enjoy with my whole heart. I am alone, and feel the charm of existence in this spot, which was created for the bliss of souls like mine. I am so happy, my dear friend, so absorbed in the exquisite sense of mere tranquil existence, that I neglect my talents. I should be incapable of drawing a single stroke at the present moment; and yet I feel that I never was a greater artist than now. When, while the lovely valley teems with vapour around me, and the meridian sun strikes the upper surface of the impenetrable foliage of my trees, and but a few stray gleams steal into the inner sanctuary, I throw myself down among the tall grass by the trickling stream; and, as I lie close to the earth, a thousand unknown plants are noticed by me: when I hear the buzz of the little world among the stalks, and grow familiar with the countless indescribable forms of the insects and flies, then I feel the presence of the Almighty, who formed us in his own image, and the breath of that universal love which bears and sustains us, as it floats around us in an eternity of bliss; and then, my friend, when darkness overspreads my eyes, and heaven and earth seem to dwell in my soul and absorb its power, like the form of a beloved mistress, then I often think with longing, Oh, would I could describe these conceptions, could impress upon paper all that is living so full and warm within me, that it might be the mirror of my soul, as my soul is the mirror of the infinite God! O my friend -- but it is too much for my strength -- I sink under the weight of the splendour of these visions! A wonderful serenity has taken possession of my entire soul, like these sweet mornings of spring which I enjoy with my whole heart. I am alone, and feel the charm of existence in this spot, which was created for the bliss of souls like mine. I am so happy, my dear friend, so absorbed in the exquisite sense of mere tranquil existence, that I neglect my talents. I should be incapable of drawing a single stroke at the present moment; and yet I feel that I never was a greater artist than now. When, while the lovely valley teems with vapour around me, and the meridian sun strikes the upper surface of the impenetrable foliage of my trees, and but a few stray gleams steal into the inner sanctuary, I throw myself down among the tall grass by the trickling stream; and, as I lie close to the earth, a thousand unknown plants are noticed by me: when I hear the buzz of the little world among the stalks, and grow familiar with the countless indescribable forms of the insects and flies, then I feel the presence of the Almighty, who formed us in his own image, and the breath of that universal love which bears and sustains us, as it floats around us in an eternity of bliss; and then, my friend, when darkness overspreads my eyes, and heaven and earth seem to dwell in my soul and absorb its power, like the form of a beloved mistress, then I often think with longing, Oh, would I could describe these conceptions, could impress upon paper all that is living so full and warm within me, that it might be the mirror of my soul, as my soul is the mirror of the infinite God! O my friend -- but it is too much for my strength -- I sink under the weight of the splendour of these visions!A wonderful serenity has taken possession of my entire soul, like these sweet mornings of spring which I enjoy with my whole heart. I am alone, and feel the charm of existence in this spot, which was created for the bliss of souls').split(" ")

fn greek_text_to_keys() raises -> DynamicVector[String]:
    return (cwd() / "corpora" / "greek.txt").read_text().replace("\n", " ").split(" ")

fn hebrew_text_to_keys() raises -> DynamicVector[String]:
    return (cwd() / "corpora" / "hebrew.txt").read_text().replace("\n", " ").split(" ")

fn arabic_text_to_keys() raises -> DynamicVector[String]:
    return (cwd() / "corpora" / "arabic.txt").read_text().replace("\n", " ").split(" ")

fn l33t_text_to_keys() raises -> DynamicVector[String]:
    return (cwd() / "corpora" / "l33t.txt").read_text().replace("\n", " ").split(" ")

fn georgian_text_to_keys() raises -> DynamicVector[String]:
    return (cwd() / "corpora" / "georgian.txt").read_text().replace("\n", " ").split(" ")

fn chinese_text_to_keys() raises -> DynamicVector[String]:
    return (cwd() / "corpora" / "chinese.txt").read_text().replace("\n", " ").split(" ")

fn french_text_to_keys() raises -> DynamicVector[String]:
    return (cwd() / "corpora" / "french.txt").read_text().replace("\n", " ").split(" ")

fn hindi_text_to_keys() raises -> DynamicVector[String]:
    return (cwd() / "corpora" / "hindi.txt").read_text().replace("\n", " ").split(" ")


fn russian_text_to_keys() raises -> DynamicVector[String]:
    return String('Проснувшись однажды утром после беспокойного сна, Грегор Замза обнаружил, что он у себя в постели превратился в страшное насекомое. Лежа на панцирнотвердой спине, он видел, стоило ему приподнять голову, свой коричневый, выпуклый, разделенный дугообразными чешуйками живот, на верхушке которого еле держалось готовое вот-вот окончательно сползти одеяло. Его многочисленные, убого тонкие по сравнению с остальным телом ножки беспомощно копошились у него перед глазами. «Что со мной случилось?» – подумал он. Это не было сном. Его комната, настоящая, разве что слишком маленькая, но обычная комната, мирно покоилась в своих четырех хорошо знакомых стенах. Над столом, где были разложены распакованные образцы сукон – Замза был коммивояжером, – висел портрет, который он недавно вырезал из иллюстрированного журнала и вставил в красивую золоченую рамку. На портрете была изображена дама в меховой шляпе и боа, она сидела очень прямо и протягивала зрителю тяжелую меховую муфту, в которой целиком исчезала ее рука. Затем взгляд Грегора устремился в окно, и пасмурная погода – слышно было, как по жести подоконника стучат капли дождя – привела его и вовсе в грустное настроение. «Хорошо бы еще немного поспать и забыть всю эту чепуху», – подумал он, но это было совершенно неосуществимо, он привык спать на правом боку, а в теперешнем своем состоянии он никак не мог принять этого положения. С какой бы силой ни поворачивался он на правый бок, он неизменно сваливался опять на спину. Закрыв глаза, чтобы не видеть своих барахтающихся ног, он проделал это добрую сотню раз и отказался от этих попыток только тогда, когда почувствовал какую-то неведомую дотоле, тупую и слабую боль в боку. «Ах ты, господи, – подумал он, – какую я выбрал хлопотную профессию! Изо дня в день в разъездах. Деловых волнений куда больше, чем на месте, в торговом доме, а кроме того, изволь терпеть тяготы дороги, думай о расписании поездов, мирись с плохим, нерегулярным питанием, завязывай со все новыми и новыми людьми недолгие, никогда не бывающие сердечными отношения. Черт бы побрал все это!» Он почувствовал вверху живота легкий зуд; медленно подвинулся на спине к прутьям кровати, чтобы удобнее было поднять голову; нашел зудевшее место, сплошь покрытое, как оказалось, белыми непонятными точечками; хотел было ощупать это место одной из ножек, но сразу отдернул ее, ибо даже простое прикосновение вызвало у него, Грегора, озноб. Он соскользнул в прежнее свое положение. «От этого раннего вставания, – подумал он, – можно совсем обезуметь. Человек должен высыпаться. Другие коммивояжеры живут, как одалиски. Когда я, например, среди дня возвращаюсь в гостиницу, чтобы переписать полученные заказы, эти господа только завтракают. А осмелься я вести себя так, мои хозяин выгнал бы меня сразу. Кто знает, впрочем, может быть, это было бы даже очень хорошо для меня. Если бы я не сдерживался ради родителей, я бы давно заявил об уходе, я бы подошел к своему хозяину и выложил ему все, что о нем думаю. Он бы так и свалился с конторки! Странная у него манера – садиться на конторку и с ее высоты разговаривать со служащим, который вдобавок вынужден подойти вплотную к конторке из-за того, что хозяин туг на ухо. Однако надежда еще не совсем потеряна: как только я накоплю денег, чтобы выплатить долг моих родителей – на это уйдет еще лет пять-шесть, – я так и поступлю. Тут-то мы и распрощаемся раз и навсегда. А пока что надо подниматься, мой поезд отходит в пять». И он взглянул на будильник, который тикал на сундуке. «Боже правый!» – подумал он. Было половина седьмого, и стрелки спокойно двигались дальше, было даже больше половины, без малого уже три четверти. Неужели будильник не звонил? С кровати было видно, что он поставлен правильно, на четыре часа; и он, несомненно, звонил. Но как можно было спокойно спать под этот сотрясающий мебель трезвон? Ну, спал-то он неспокойно, но, видимо, крепко. Однако что делать теперь? Следующий поезд уходит в семь часов; чтобы поспеть на него, он должен отчаянно торопиться, а набор образцов еще не упакован, да и сам он отнюдь не чувствует себя свежим и легким на подъем. И даже поспей он на поезд, хозяйского разноса ему все равно не избежать – ведь рассыльный торгового дома дежурил у пятичасового поезда и давно доложил о его, Грегора, опоздании. Рассыльный, человек бесхарактерный и неумный, был ставленником хозяина. А что, если сказаться больным? Но это было бы крайне неприятно и показалось бы подозрительным, ибо за пятилетнюю свою службу Грегор ни разу еще не болел. Хозяин, конечно, привел бы врача больничной кассы и стал попрекать родителей сыном-лентяем, отводя любые возражения ссылкой на этого врача, по мнению которого все люди на свете совершенно здоровы и только не любят работать. И разве в данном случае он был бы так уж неправ? Если не считать сонливости, действительно странной после такого долгого сна, Грегор и в самом деле чувствовал себя превосходно и был даже чертовски голоден.Проснувшись однажды утром после беспокойного сна, Грегор Замза обнаружил, что он у себя в постели превратился в страшное насекомое. Лежа на панцирнотвердой спине, он видел, стоило ему приподнять голову, свой коричневый, выпуклый, разделенный дугообразными чешуйками живот, на верхушке которого еле держалось готовое вот-вот окончательно сползти одеяло. Его многочисленные, убого тонкие по сравнению с остальным телом ножки беспомощно копошились у него перед глазами. «Что со мной случилось?» – подумал он. Это не было сном. Его комната, настоящая, разве что слишком маленькая, но обычная комната, мирно покоилась в своих четырех хорошо знакомых стенах. Над столом, где были разложены распакованные образцы сукон – Замза был коммивояжером, – висел портрет, который он недавно вырезал из иллюстрированного журнала и вставил в красивую золоченую рамку. На портрете была изображена дама в меховой шляпе и боа, она сидела очень прямо и протягивала зрителю тяжелую меховую муфту, в которой целиком исчезала ее рука. Затем взгляд Грегора устремился в окно, и пасмурная погода – слышно было, как по жести подоконника стучат капли дождя – привела его и вовсе в грустное настроение. «Хорошо бы еще немного поспать и забыть всю эту чепуху», – подумал он, но это было совершенно неосуществимо, он привык спать на правом боку, а в теперешнем своем состоянии он никак не мог принять этого положения. С какой бы силой ни поворачивался он на правый бок, он неизменно сваливался опять на спину.').split(" ")

fn german_text_to_keys() raises -> DynamicVector[String]:
    return String('Weit hinten, hinter den Wortbergen, fern der Länder Vokalien und Konsonantien leben die Blindtexte. Abgeschieden wohnen sie in Buchstabhausen an der Küste des Semantik, eines großen Sprachozeans. Ein kleines Bächlein namens Duden fließt durch ihren Ort und versorgt sie mit den nötigen Regelialien. Es ist ein paradiesmatisches Land, in dem einem gebratene Satzteile in den Mund fliegen. Nicht einmal von der allmächtigen Interpunktion werden die Blindtexte beherrscht – ein geradezu unorthographisches Leben. Eines Tages aber beschloß eine kleine Zeile Blindtext, ihr Name war Lorem Ipsum, hinaus zu gehen in die weite Grammatik. Der große Oxmox riet ihr davon ab, da es dort wimmele von bösen Kommata, wilden Fragezeichen und hinterhältigen Semikoli, doch das Blindtextchen ließ sich nicht beirren. Es packte seine sieben Versalien, schob sich sein Initial in den Gürtel und machte sich auf den Weg. Als es die ersten Hügel des Kursivgebirges erklommen hatte, warf es einen letzten Blick zurück auf die Skyline seiner Heimatstadt Buchstabhausen, die Headline von Alphabetdorf und die Subline seiner eigenen Straße, der Zeilengasse. Wehmütig lief ihm eine rhetorische Frage über die Wange, dann setzte es seinen Weg fort. Unterwegs traf es eine Copy. Die Copy warnte das Blindtextchen, da, wo sie herkäme wäre sie zigmal umgeschrieben worden und alles, was von ihrem Ursprung noch übrig wäre, sei das Wort "und" und das Blindtextchen solle umkehren und wieder in sein eigenes, sicheres Land zurückkehren. Doch alles Gutzureden konnte es nicht überzeugen und so dauerte es nicht lange, bis ihm ein paar heimtückische Werbetexter auflauerten, es mit Longe und Parole betrunken machten und es dann in ihre Agentur schleppten, wo sie es für ihre Projekte wieder und wieder mißbrauchten. Und wenn es nicht umgeschrieben wurde, dann benutzen Sie es immernoch. Weit hinten, hinter den Wortbergen, fern der Länder Vokalien und Konsonantien leben die Blindtexte. Abgeschieden wohnen sie in Buchstabhausen an der Küste des Semantik, eines großen Sprachozeans. Ein kleines Bächlein namens Duden fließt durch ihren Ort und versorgt sie mit den nötigen Regelialien. Es ist ein paradiesmatisches Land, in dem einem gebratene Satzteile in den Mund fliegen. Nicht einmal von der allmächtigen Interpunktion werden die Blindtexte beherrscht – ein geradezu unorthographisches Leben. Eines Tages aber beschloß eine kleine Zeile Blindtext, ihr Name war Lorem Ipsum, hinaus zu gehen in die weite Grammatik. Der große Oxmox riet ihr davon ab, da es dort wimmele von bösen Kommata, wilden Fragezeichen und hinterhältigen Semikoli, doch das Blindtextchen ließ sich nicht beirren. Es packte seine sieben Versalien, schob sich sein Initial in den Gürtel und machte sich auf den Weg. Als es die ersten Hügel des Kursivgebirges erklommen hatte, warf es einen letzten Blick zurück auf die Skyline seiner Heimatstadt Buchstabhausen, die Headline von Alphabetdorf und die Subline seiner eigenen Straße, der Zeilengasse. Wehmütig lief ihm eine rhetorische Frage über die Wange, dann setzte es seinen Weg fort. Unterwegs traf es eine Copy. Die Copy warnte das Blindtextchen, da, wo sie herkäme wäre sie zigmal umgeschrieben worden und alles, was von ihrem Ursprung noch übrig wäre, sei das Wort "und" und das Blindtextchen solle umkehren und wieder in sein eigenes, sicheres Land zurückkehren. Doch alles Gutzureden konnte es nicht überzeugen und so dauerte es nicht lange, bis ihm ein paar heimtückische Werbetexter auflauerten, es mit Longe und Parole betrunken machten und es dann in ihre Agentur schleppten, wo sie es für ihre Projekte wieder und wieder mißbrauchten. Und wenn es nicht umgeschrieben wurde, dann benutzen Sie es immernoch. Weit hinten, hinter den Wortbergen, fern der Länder Vokalien und Konsonantien leben die Blindtexte. Abgeschieden wohnen sie in Buchstabhausen an der Küste des Semantik, eines großen Sprachozeans. Ein kleines Bächlein namens Duden fließt durch ihren Ort und versorgt sie mit den nötigen Regelialien. Es ist ein paradiesmatisches Land, in dem einem gebratene Satzteile in den Mund fliegen. Nicht einmal von der allmächtigen Interpunktion werden die Blindtexte beherrscht – ein geradezu unorthographisches Leben. Eines Tages aber beschloß eine kleine Zeile Blindtext, ihr Name war Lorem Ipsum, hinaus zu gehen in die weite Grammatik. Der große Oxmox riet ihr davon ab, da es dort wimmele von bösen Kommata, wilden Fragezeichen und hinterhältigen Semikoli, doch das Blindtextchen ließ sich nicht beirren. Es packte seine sieben Versalien, schob sich sein Initial in den Gürtel und machte sich auf den Weg. Als es die ersten Hügel des Kursivgebirges erklommen hatte, warf es einen letzten Blick zurück auf die Skyline seiner Heimatstadt Buchstabhausen, die Headline von Alphabetdorf und die Subline seiner eigenen Straße, der Zeilengasse. Wehmütig lief ihm eine rhetorische Frage über die Wange, dann setzte es seinen Weg fort. Unterwegs traf es eine Copy. Die Copy warnte das Blindtextchen, da, wo sie herkäme wäre sie zigmal umgeschrieben worden und alles, was von ihrem Ursprung noch übrig wäre, sei das Wort "und" und das Blindtextchen solle umkehren und wieder in sein eigenes, sicheres Land zurückkehren. Doch alles Gutzureden konnte es nicht überzeugen und so dauerte es nicht lange, bis ihm ein paar heimtückische Werbetexter auflauerten, es mit Longe und Parole betrunken machten und es dann in ihre Agentur schleppten, wo sie es für ihre Projekte wieder und wieder mißbrauchten. Und wenn es nicht umgeschrieben wurde, dann benutzen Sie es immernoch.Weit hinten, hinter den Wortbergen, fern der Länder Vokalien und Konsonantien leben die Blindtexte. Abgeschieden wohnen sie in Buchstabhausen an der Küste des Semantik, eines großen Sprachozeans. Ein kleines Bächlein namens Duden fließt durch ihren Ort und versorgt sie mit den nötigen Regelialien. Es ist ein paradiesmatisches Land, in dem einem gebratene Satzteile in den Mund fliegen. Nicht einmal von der allmächtigen Interpunktion werden die Blindtexte beherrscht – ein geradezu unorthographisches Leben. Eines Tages aber beschloß eine kleine Zeile Blindtext, ihr Name war Lorem Ipsum, hinaus zu gehen in die weite Grammatik. Der große Oxmox riet ihr davon ab, da es dort wimmele von bösen Kommata, wilden Fragezeichen und hinterhältigen Semikoli, doch das Blindtextchen ließ sich nicht beirren. Es packte seine sieben Versalien, schob sich sein Initial in den Gürtel und machte sich auf den Weg. Als es die ersten Hügel des Kursivgebirges erklommen hatte, warf es einen').split(" ")

fn japanese_long_keys() raises -> DynamicVector[String]:
    return String('米くを舵4物委らご氏松ハナテフ月関ソ時平ふいの博情れじフ牟万い元56園フメヤオ試図ロツヤ未備王こと傷喫羅踊んゆし。栃ユヱオ書著作ユソツロ英祉業ア大課ご権質フべ空8午キ切軟づン著郎そゃす格町採ヱオマコ処8付国ムハチア究表でなだ際無ロミヱ地兵ぴげ庭体すク発抜爆位や。楽富むゆず盛航カナセ携代ハ本高きた員59今骸ンラえぜ城解イケ穴訴ぽぎ属住ヤケトヌ抱点ト広注厚でて。 国リ出難セユメ軍手ヘカウ画形サヲシ猛85用ヲキミ心死よしと身処ケヨミオ教主ーぽ事業んく字国たさょ図能シミスヤ社8板ル岡世58次戒知院んれり。市メ誘根カ数問禁竹ゃれえみ給辺のでみき今二ぎさ裕止過こクすと無32郎所ラた生展ヌヘス成度慣葬勇厘ばてか。室ゃ下携疲ム色権がぽりっ銃週ノオ姫千テム健蔵い研手ッ放容ル告属め旅側26企サノヨ宅都福ぞ通待ちぴね種脳イど労希望義通むン。 罰しい続負せ著低たル異師ユハワ東添質コチ転集ルヤ雇聴約ヒ前統らた情厳ゆさでや真胸や有披暑棚豆ゆぼたけ。盛ワセロナ情競クるっわ講3音ずをせ少地めしぜょ手63明視れに判企ヒヌエソ求総58特本ね井比ユラキ禁頭馬るゅリす能率率かがさわ。葉サソ医郡ヱヘソ労帰ナケスミ救写ワヘ株審ネヒニミ安逮イ人画ラ涯車はラ極騒りなド件5級ンかふー劇41著ぱぐ凱討だ文世ぶづどま界善魅マ渓経競融れがや。 連ーぜらご模分ッ視外ばフく運発群ほぼづ育越一ほごクけ案募ヲイソ治会イせフ製君ぜた漢村1変リヒ構5際ツ御文ヲ臭入さドぼ代書ハケ引技ろみれ回観注倉徹ぱ。論ラづ海要サ情座ゃり齢宣ラモエ芸化エマホ覧催回ら戦69本外ト葬岳な政画か連針ぴリフず。約ル闘辺ぽ経2応掲ホサアラ塾小コラ画決クノオ上室レヌヱ勝逮ぜるえむ責豊チノ明意ひけ訟6碁草メタチエ財午召喝塊む。 決めでわ名金つけレわ続人県約ぽぼす尾腹ユサ戦載リシ護賀レモフツ重涯ニ治者むんっみ職更カタチレ提話2何ワ責東まけげふ能政ヌ供禁がびてわ提改倶れめ。読み担後ぽ安加ぎ論鹿ツ統最お気麻月つじもあ竜思いろめ判必満理トコ文連ムイウハ寄串ざほびー。文ゆこっ向27年メイ便能ノセヲ待1王スねたゆ伝派んね点過カト治読よにきべ使人スシ都言え阻8割べづえみ注引敷的岳犠眠どそ。 学用イだ医客開ロ供界もぞだ実隆モイヌ務坂ナコヲ権野ろづ初場ぱ低会づぱじ新倒コ化政レ止奮浸猪ッわえづ。形いやリ要帰ほまむだ業領スル必打さ島14巻リ集日ネヘホタ面幅ち写上そぴ円図ムタコモ報使イわざと会催ヤヲ康証をドぶレ盤岡ホハツ作29管しをめ公問懐蓄っさ。来ゆぼあぱ投秋シ語右ぐ身靖かば辛握捕家記ヘワ神岐囲づ毘観メテクツ政73夕罪57需93誌飲査仁さ。 変レめ束球よんま会特ヱコ聞重だ史純ーどる件32浦レぴよゃ上強ネラリロ査従セユヤ専棋光レ作表ひぶ予正ぜーな誉確フス函6報円ス進治ね能営済否雄でわょ。42生型ば着続ア短実ぎおめび前環闘ラヤヲル診均っとにの声公トヱテマ整試椅情久妊舌頃ざとっく。品キチトテ阿国ラら受87世ヲフセリ川86個ーょぼげ危子ヘレカメ無会ぱかへ事通んかて電条ロツ徴商ぶぞそを居暑メ害広せもがり禁応レミヲ応響割壮憶はぱ。 千れンが織財メニ況界ネトレミ学豊フオホシ近月レたやご的罪ょな菱技ちる警栗エセ提89林危氷48参ア説森クキヒヱ薬社ホコエリ負和ルび紀下ケミイ掲歳特ごず扱底ク護木連ちクを各形ばすか。変ぱなれ町7融ヌ街準以タユヘム質裕ぶで遺語俊ぎずょ事金文キ写多山ーゆに歩帯すで会世クぜよ論写ヲ達71林危氷5間続ぎぜび高怠す。 係8青け応著ミ戦条ナヘネカ思79未ぎ算伊をゃ泉人ーづ需説っ畑鹿27軽ラソツ権2促千護ルロナカ開国ケ暴嶋ご池表だ。佐フナ訪麻はてせば勝効をあ医戦画とさわぴ者両すいあ並来んば載食ぴ件友頂業へえぞ魚祝ネラ聞率スコリケ始全ンこび夫出ドふ今布うぎふゅ実克即哉循やしんな。 暮す備54依紀てッん末刊と柔称むてス無府ケイ変壌をぱ汁連フマス海世ヌ中負知問ナヘケ純推ひ読着ヒ言若私軽れ。掲けフむ王本オコ線人をっさ必和断セソヲハ図芸ちかな防長りぶは投新意相ツ並5余セ職岳ぞ端古空援そ。森ヨエチ題5東っ自兄ち暴5近鹿横ト的京ハ安氷ナキ深際ぎ並節くスむの権工ほルせ京49効タムチ処三ぞぴラ済国ずっ文経ヘトミ水分準そが。').split(" ")

fn s3_action_names() raises -> DynamicVector[String]:
    return String('AbortMultipartUpload CompleteMultipartUpload CopyObject CreateBucket CreateMultipartUpload DeleteBucket DeleteBucketAnalyticsConfiguration DeleteBucketCors DeleteBucketEncryption DeleteBucketIntelligentTieringConfiguration DeleteBucketInventoryConfiguration DeleteBucketLifecycle DeleteBucketMetricsConfiguration DeleteBucketOwnershipControls DeleteBucketPolicy DeleteBucketReplication DeleteBucketTagging DeleteBucketWebsite DeleteObject DeleteObjects DeleteObjectTagging DeletePublicAccessBlock GetBucketAccelerateConfiguration GetBucketAcl GetBucketAnalyticsConfiguration GetBucketCors GetBucketEncryption GetBucketIntelligentTieringConfiguration GetBucketInventoryConfiguration GetBucketLifecycle GetBucketLifecycleConfiguration GetBucketLocation GetBucketLogging GetBucketMetricsConfiguration GetBucketNotification GetBucketNotificationConfiguration GetBucketOwnershipControls GetBucketPolicy GetBucketPolicyStatus GetBucketReplication GetBucketRequestPayment GetBucketTagging GetBucketVersioning GetBucketWebsite GetObject GetObjectAcl GetObjectAttributes GetObjectLegalHold GetObjectLockConfiguration GetObjectRetention GetObjectTagging GetObjectTorrent GetPublicAccessBlock HeadBucket HeadObject ListBucketAnalyticsConfigurations ListBucketIntelligentTieringConfigurations ListBucketInventoryConfigurations ListBucketMetricsConfigurations ListBuckets ListMultipartUploads ListObjects ListObjectsV2 ListObjectVersions ListParts PutBucketAccelerateConfiguration PutBucketAcl PutBucketAnalyticsConfiguration PutBucketCors PutBucketEncryption PutBucketIntelligentTieringConfiguration PutBucketInventoryConfiguration PutBucketLifecycle PutBucketLifecycleConfiguration PutBucketLogging PutBucketMetricsConfiguration PutBucketNotification PutBucketNotificationConfiguration PutBucketOwnershipControls PutBucketPolicy PutBucketReplication PutBucketRequestPayment PutBucketTagging PutBucketVersioning PutBucketWebsite PutObject PutObjectAcl PutObjectLegalHold PutObjectLockConfiguration PutObjectRetention PutObjectTagging PutPublicAccessBlock RestoreObject SelectObjectContent UploadPart UploadPartCopy WriteGetObjectResponse", "CreateAccessPoint CreateAccessPointForObjectLambda CreateBucket CreateJob CreateMultiRegionAccessPoint DeleteAccessPoint DeleteAccessPointForObjectLambda DeleteAccessPointPolicy DeleteAccessPointPolicyForObjectLambda DeleteBucket DeleteBucketLifecycleConfiguration DeleteBucketPolicy DeleteBucketReplication DeleteBucketTagging DeleteJobTagging DeleteMultiRegionAccessPoint DeletePublicAccessBlock DeleteStorageLensConfiguration DeleteStorageLensConfigurationTagging DescribeJob DescribeMultiRegionAccessPointOperation GetAccessPoint GetAccessPointConfigurationForObjectLambda GetAccessPointForObjectLambda GetAccessPointPolicy GetAccessPointPolicyForObjectLambda GetAccessPointPolicyStatus GetAccessPointPolicyStatusForObjectLambda GetBucket GetBucketLifecycleConfiguration GetBucketPolicy GetBucketReplication GetBucketTagging GetBucketVersioning GetJobTagging GetMultiRegionAccessPoint GetMultiRegionAccessPointPolicy GetMultiRegionAccessPointPolicyStatus GetMultiRegionAccessPointRoutes GetPublicAccessBlock GetStorageLensConfiguration GetStorageLensConfigurationTagging ListAccessPoints ListAccessPointsForObjectLambda ListJobs ListMultiRegionAccessPoints ListRegionalBuckets ListStorageLensConfigurations PutAccessPointConfigurationForObjectLambda PutAccessPointPolicy PutAccessPointPolicyForObjectLambda PutBucketLifecycleConfiguration PutBucketPolicy PutBucketReplication PutBucketTagging PutBucketVersioning PutJobTagging PutMultiRegionAccessPointPolicy PutPublicAccessBlock PutStorageLensConfiguration PutStorageLensConfigurationTagging SubmitMultiRegionAccessPointRoutes UpdateJobPriority UpdateJobStatus').split(" ")

fn system_words_collection() raises -> DynamicVector[String]:
    return Path("/usr/share/dict/words").read_text().split("\n")

@value
struct StringKey(KeyElement):
    var s: String

    fn __init__(inout self, owned s: String):
        self.s = s^

    fn __init__(inout self, s: StringLiteral):
        self.s = String(s)

    fn __hash__(self) -> Int:
        let ptr = self.s._as_ptr()
        return hash(ptr, len(self.s))

    fn __eq__(self, other: Self) -> Bool:
        return self.s == other.s

fn corpus_stats(corpus: DynamicVector[String]):
    print("=======Corpus Stats=======")
    print("Number of elements:", len(corpus))
    var min = 100000000
    var max = 0
    var sum = 0
    var count = 0
    for i in range(len(corpus)):
        let key = corpus[i]
        if len(key) == 0:
            continue
        count += 1
        sum += len(key)
        if min > len(key):
            min = len(key)
        if max < len(key):
            max = len(key)
    let avg = sum / count
    print("Min key lenght:", min)
    print("Avg key length:", avg)
    print("Max key length:", max)
    print("\n")

fn main() raises:
    var d1 = Dict[Int]()
    var d2 = StdDict[StringKey, Int]()
    var corpus = chinese_text_to_keys()

    corpus_stats(corpus)

    @parameter
    fn build_compact_dict():
        var d = Dict[Int](len(corpus))
        # var d = Dict[Int]()
        for i in range(len(corpus)):
            d.put(corpus[i], i)
        d1 = d^

    @parameter
    fn build_std_dict():
        var d = StdDict[StringKey, Int]()
        for i in range(len(corpus)):
            d[corpus[i]] = i
        d2 = d^

    print("+++++++Create Dict Benchmark+++++++")

    let build_compact_stats = benchmark.run[build_compact_dict](max_runtime_secs=0.5)
    build_compact_stats.print("ns")

    let build_std_stats = benchmark.run[build_std_dict](max_runtime_secs=0.5)
    build_std_stats.print("ns")

    print("Compact build speedup:", build_std_stats.mean() / build_compact_stats.mean())
    print("\n\n\n")
    var sum1 = 0
    @parameter
    fn read_compact_dict():
        sum1 = 0
        for i in range(len(corpus)):
            sum1 += d1.get(corpus[i], -1)

    print("+++++++Read Dict Benchmark+++++++")

    let read_compact_stats = benchmark.run[read_compact_dict](max_runtime_secs=0.5)
    print("Compact sum1:", sum1)
    read_compact_stats.print("ns")

    var sum2 = 0
    @parameter
    fn read_std_dict():
        sum2 = 0
        for i in range(len(corpus)):
            try:
                sum2 += d2[corpus[i]]
            except:
                sum2 += -1

    let raed_std_stats = benchmark.run[read_std_dict](max_runtime_secs=0.5)
    raed_std_stats.print("ns")
    print("Compact sum2:", sum2)
    print("Compact read speedup:", raed_std_stats.mean() / read_compact_stats.mean())
    
    assert_equal(sum1, sum2)
    
    _ = corpus
    _ = d1^
    _ = d2^