class Quran {
  final String verse;
  final String surah;
  final String ayah;

  Quran({required this.verse, required this.surah, required this.ayah});
}

List<Quran> quranicVerses = [
  Quran(
      verse: 'In the name of Allah, the Most Gracious, the Most Merciful.',
      surah: 'Al-Fatiha',
      ayah: '1:1'),
  Quran(
      verse: 'Praise be to Allah, the Lord of all the worlds.',
      surah: 'Al-Fatiha',
      ayah: '1:2'),
  Quran(
      verse: 'The Most Gracious, the Most Merciful.',
      surah: 'Al-Fatiha',
      ayah: '1:3'),
  Quran(
      verse: 'Master of the Day of Judgment.', surah: 'Al-Fatiha', ayah: '1:4'),
  Quran(
      verse: 'You alone we worship, and You alone we ask for help.',
      surah: 'Al-Fatiha',
      ayah: '1:5'),
  Quran(
      verse: 'Guide us on the Straight Path.', surah: 'Al-Fatiha', ayah: '1:6'),
  Quran(
      verse:
          'The path of those who have received Your grace; not the path of those who have brought down wrath upon themselves, nor of those who have gone astray.',
      surah: 'Al-Fatiha',
      ayah: '1:7'),
  Quran(
      verse:
          'Indeed, Allah does not wrong the people at all, but it is the people who are wronging themselves.',
      surah: 'Yunus',
      ayah: '10:44'),
  Quran(
      verse: 'And whoever fears Allah - He will make for him a way out.',
      surah: 'At-Talaq',
      ayah: '65:2'),
  Quran(
      verse:
          'Indeed, Allah is with those who fear Him and those who are doers of good.',
      surah: 'An-Nahl',
      ayah: '16:128'),
  Quran(
      verse:
          'Indeed, Allah will not change the condition of a people until they change what is in themselves.',
      surah: 'Ar-Rad',
      ayah: '13:11'),
  Quran(
      verse: 'Say, "He is Allah, [who is] One.',
      surah: 'Al-Ikhlas',
      ayah: '112:1'),
  Quran(verse: 'Allah, the Eternal Refuge.', surah: 'Al-Ikhlas', ayah: '112:2'),
  Quran(
      verse: 'He neither begets nor is born.',
      surah: 'Al-Ikhlas',
      ayah: '112:3'),
  Quran(
      verse: 'Nor is there to Him any equivalent."',
      surah: 'Al-Ikhlas',
      ayah: '112:4'),
  Quran(
      verse:
          'And We have not sent you, [O Muhammad], except as a mercy to the worlds.',
      surah: 'Al-Anbiya',
      ayah: '21:107'),
  Quran(
      verse:
          'And We have certainly made the Qur\'an easy for remembrance, so is there any who will remember?',
      surah: 'Al-Qamar',
      ayah: '54:17'),
  Quran(
      verse:
          'Indeed, this Qur\'an guides to that which is most suitable and gives good tidings to the believers who do righteous deeds that they will have a great reward.',
      surah: 'Al-Isra',
      ayah: '17:9'),
  Quran(
      verse:
          'O mankind, worship your Lord, who created you and those before you, that you may become righteous.',
      surah: 'Al-Baqarah',
      ayah: '2:21'),
  Quran(
      verse:
          'And seek help through patience and prayer, and indeed, it is difficult except for the humbly submissive [to Allah].',
      surah: 'Al-Baqarah',
      ayah: '2:45'),
  Quran(
      verse: 'Indeed, Allah is with the patient.',
      surah: 'Al-Baqarah',
      ayah: '2:153'),
  Quran(
      verse:
          'So remember Me; I will remember you. And be grateful to Me and do not deny Me.',
      surah: 'Al-Baqarah',
      ayah: '2:152'),
  Quran(
      verse: 'Indeed, Allah loves those who rely [upon Him].',
      surah: 'Aal-E-Imran',
      ayah: '3:159'),
  Quran(
      verse:
          'And whoever fears Allah - He will make for him of his matter ease.',
      surah: 'At-Talaq',
      ayah: '65:4'),
  Quran(
      verse: 'And My mercy encompasses all things.',
      surah: 'Al-Araf',
      ayah: '7:156'),
  Quran(
      verse: 'So be patient. Indeed, the promise of Allah is truth.',
      surah: 'Ar-Rum',
      ayah: '30:60'),
  Quran(
      verse: 'And He found you lost and guided [you].',
      surah: 'Ad-Duhaa',
      ayah: '93:7'),
  Quran(
      verse: 'And He found you poor and made [you] self-sufficient.',
      surah: 'Ad-Duhaa',
      ayah: '93:8'),
  Quran(
      verse: 'So as for the orphan, do not oppress [him].',
      surah: 'Ad-Duhaa',
      ayah: '93:9'),
  Quran(
      verse: 'And as for the petitioner, do not repel [him].',
      surah: 'Ad-Duhaa',
      ayah: '93:10'),
  Quran(
      verse: 'But as for the favor of your Lord, report [it].',
      surah: 'Ad-Duhaa',
      ayah: '93:11'),
  Quran(
      verse:
          'O you who have believed, fear Allah as He should be feared and do not die except as Muslims [in submission to Him].',
      surah: 'Aal-E-Imran',
      ayah: '3:102'),
  Quran(
      verse:
          'And hold firmly to the rope of Allah all together and do not become divided.',
      surah: 'Aal-E-Imran',
      ayah: '3:103'),
  Quran(
      verse: 'Indeed, the religion in the sight of Allah is Islam.',
      surah: 'Aal-E-Imran',
      ayah: '3:19'),
  Quran(
      verse:
          'And rely upon the Ever-Living who does not die, and exalt [Allah] with His praise.',
      surah: 'Al-Furqan',
      ayah: '25:58'),
  Quran(
      verse: 'And We have certainly honored the children of Adam.',
      surah: 'Al-Isra',
      ayah: '17:70'),
  Quran(
      verse: 'And your Lord is going to give you, and you will be satisfied.',
      surah: 'Ad-Duhaa',
      ayah: '93:5'),
  Quran(
      verse:
          'And you do not will except that Allah wills - Lord of the worlds.',
      surah: 'At-Takwir',
      ayah: '81:29'),
  Quran(
      verse: 'And say, "My Lord, increase me in knowledge."',
      surah: 'Taha',
      ayah: '20:114'),
  Quran(
      verse: 'So verily, with the hardship, there is relief.',
      surah: 'Ash-Sharh',
      ayah: '94:6'),
  Quran(
      verse:
          'And when you have finished [your duties], then stand up [for worship].',
      surah: 'Ash-Sharh',
      ayah: '94:7'),
  Quran(
      verse: 'And to your Lord direct [your] longing.',
      surah: 'Ash-Sharh',
      ayah: '94:8'),
  Quran(
      verse:
          'And say, "Truth has come, and falsehood has departed. Indeed is falsehood, [by nature], ever bound to depart."',
      surah: 'Al-Isra',
      ayah: '17:81'),
  Quran(
      verse: 'Indeed, the righteous will be among gardens and springs.',
      surah: 'Adh-Dhariyat',
      ayah: '51:15'),
  Quran(
      verse:
          'Indeed, we have sent you as a witness and a bringer of good tidings and a warner.',
      surah: 'Al-Fath',
      ayah: '48:8'),
  Quran(
      verse:
          'And We have not created the heavens and earth and that between them except in truth.',
      surah: 'Al-Hijr',
      ayah: '15:85'),
  Quran(
      verse:
          'Indeed, it is We who sent down the Qur\'an and indeed, We will be its guardian.',
      surah: 'Al-Hijr',
      ayah: '15:9'),
  Quran(
      verse:
          'And those who believe and do righteous deeds - We will surely remove from them their misdeeds and will surely reward them according to the best of what they used to do.',
      surah: 'Al-Ankabut',
      ayah: '29:7'),
  Quran(
      verse: 'And He is the Forgiving, the Affectionate.',
      surah: 'Al-Buruj',
      ayah: '85:14'),
  Quran(
      verse:
          'Indeed, Allah is with those who fear Him and those who are doers of good.',
      surah: 'An-Nahl',
      ayah: '16:128')
];
