const LISTENING = [
  { level:'A2', title:'At the airport', accent:'British', text:'Good morning, this is your captain speaking. We are currently experiencing some turbulence. Please fasten your seatbelts and remain seated. The cabin crew will be coming through shortly. We expect to land in approximately twenty minutes. Thank you for your patience.' },
  { level:'A2', title:'Coffee order', accent:'American', text:'Hello, I would like a large latte with oat milk, please. And could I also get a blueberry muffin? Yes, that is all. How much is it? Twelve dollars and fifty cents. Here you go. Thank you very much, have a nice day.' },
  { level:'B1', title:'London weather forecast', accent:'British', text:'Good evening, and here is the weather forecast for London. Tonight will be cloudy with a chance of rain in the early hours. Tomorrow morning should be bright and sunny, with temperatures reaching around eighteen degrees. By the afternoon, expect some scattered showers and a light breeze from the west.' },
  { level:'B1', title:'Voicemail — rescheduling', accent:'British', text:'Hi, this is Emma. I am calling about our meeting tomorrow. Unfortunately, I need to reschedule because something urgent has come up. Could we meet instead on Friday at two o clock? Let me know if that works for you. Thanks, and sorry for the short notice.' },
  { level:'B2', title:'Job interview', accent:'American', text:'So, tell me a bit about yourself. Well, I have been working in marketing for five years, mainly focusing on digital campaigns. I enjoy challenging projects and I am always looking for ways to grow professionally. In my current role, I have led a team of four people and improved our conversion rate by thirty percent.' },
  { level:'B2', title:'Academic lecture intro', accent:'British', text:'Today we will discuss the impact of globalisation on emerging markets. Before we begin, I would like to outline three key themes that will guide our analysis. First, the role of foreign direct investment. Second, labour mobility and its economic consequences. And finally, the cultural dimensions of rapid industrialisation.' },
  { level:'C1', title:'Financial Times podcast', accent:'British', text:'The central bank signalled a more hawkish stance yesterday, prompting a selloff in bond markets. Analysts had anticipated a dovish pivot, but the committee emphasised persistent inflationary pressures. Equity markets retreated across the board, with technology stocks bearing the brunt of the correction.' }
];

const READING = [
  { level:'A2', title:'Sarah in Berlin', text:'Sarah moved to Berlin three years ago to work for a tech startup. At first, she struggled with the language barrier. But she was determined. Every morning, she spent thirty minutes listening to German podcasts, and every evening she wrote in a journal in German.', questions:[
    { q:'Why did Sarah move to Berlin?', options:['To study','To work','To travel','To teach'], correct:1 },
    { q:'How long did she listen every morning?', options:['10 minutes','30 minutes','1 hour','2 hours'], correct:1 }
  ]},
  { level:'B1', title:'The Value of Failure', text:'Thomas Edison famously remarked that he had not failed ten thousand times, but had discovered ten thousand ways that did not work. Failure, when approached with curiosity rather than shame, becomes a source of wisdom that no textbook can provide.', questions:[
    { q:'How did Edison describe his failures?', options:['As wasted time','As discoveries','As bad luck','As unimportant'], correct:1 },
    { q:'What does the author believe about failure?', options:['It should be avoided','It can provide wisdom','It always leads to success','It is overrated'], correct:1 }
  ]},
  { level:'C1', title:'The Economics of Attention', text:'In an economy saturated with information, attention has become the scarcest commodity. Herbert Simon observed as early as 1971 that a wealth of information creates a poverty of attention. Modern platforms have weaponised this insight, designing interfaces that harvest the human capacity for focus and convert it into advertising revenue.', questions:[
    { q:'What is the scarcest commodity according to the text?', options:['Money','Time','Attention','Information'], correct:2 },
    { q:'What did Simon say?', options:['Information is scarce','Information wealth creates attention poverty','Money buys attention','Attention is unlimited'], correct:1 }
  ]}
];

const WRITING_TASKS = [
  { level:'A2', text:'Опиши на английском <b>свой обычный день</b>. Что ты делаешь утром, днём, вечером? Напиши 5-8 предложений (минимум 100 слов).' },
  { level:'A2', text:'Напиши короткое письмо другу о <b>своих последних выходных</b>. Что делал? Где был? Понравилось ли?' },
  { level:'B1', text:'Опиши на английском <b>свой любимый город</b>. Почему он тебе нравится? Что там стоит посмотреть? 120-150 слов.' },
  { level:'B1', text:'Эссе: <b>«Жизнь в городе vs жизнь в деревне»</b>. Плюсы и минусы, что бы ты выбрал и почему?' },
  { level:'B2', text:'Эссе: <b>«Влияние социальных сетей на молодёжь»</b>. Аргументы за и против, вывод. 180-220 слов.' },
  { level:'B2', text:'Эссе: <b>«Что бы ты изменил в системе образования?»</b> Аргументируй, приведи примеры.' },
  { level:'C1', text:'Эссе: <b>«Искусственный интеллект и будущее работы»</b>. Экономические и этические аспекты. 220-280 слов.' },
  { level:'C1', text:'Review: <b>напиши рецензию на книгу или фильм</b>, который тебя впечатлил. Критический анализ.' }
];

const SPEAKING_TOPICS = [
  { level:'A2', prompt:'Describe your typical morning routine. What do you usually do?' },
  { level:'A2', prompt:'Talk about your favourite food. Why do you like it?' },
  { level:'B1', prompt:'What do you do in your free time and why do you enjoy it?' },
  { level:'B1', prompt:'Describe your favourite place in your city. What makes it special?' },
  { level:'B2', prompt:'Describe a difficult decision you had to make. How did you handle it?' },
  { level:'B2', prompt:'What are the advantages and disadvantages of remote work?' },
  { level:'C1', prompt:'Discuss the impact of technology on human relationships.' },
  { level:'C1', prompt:'What role does failure play in professional growth?' }
];

module.exports = { LISTENING, READING, WRITING_TASKS, SPEAKING_TOPICS };