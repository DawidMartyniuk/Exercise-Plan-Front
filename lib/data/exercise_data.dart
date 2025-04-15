
// const ExerciseData = [
//   [
//     {
//         "bodyPart": "waist",
//         "equipment": "body weight",
//         "gifUrl": "https://v2.exercisedb.io/image/yzyIGSKT3t8gqB",
//         "id": "0001",
//         "name": "3/4 sit-up",
//         "target": "abs",
//         "secondaryMuscles": [
//             "hip flexors",
//             "lower back"
//         ],
//         "instructions": [
//             "Lie flat on your back with your knees bent and feet flat on the ground.",
//             "Place your hands behind your head with your elbows pointing outwards.",
//             "Engaging your abs, slowly lift your upper body off the ground, curling forward until your torso is at a 45-degree angle.",
//             "Pause for a moment at the top, then slowly lower your upper body back down to the starting position.",
//             "Repeat for the desired number of repetitions."
//         ]
//     },
//     {
//         "bodyPart": "waist",
//         "equipment": "body weight",
//         "gifUrl": "https://v2.exercisedb.io/image/Ug3qMt1YKWZllh",
//         "id": "0002",
//         "name": "45° side bend",
//         "target": "abs",
//         "secondaryMuscles": [
//             "obliques"
//         ],
//         "instructions": [
//             "Stand with your feet shoulder-width apart and your arms extended straight down by your sides.",
//             "Keeping your back straight and your core engaged, slowly bend your torso to one side, lowering your hand towards your knee.",
//             "Pause for a moment at the bottom, then slowly return to the starting position.",
//             "Repeat on the other side.",
//             "Continue alternating sides for the desired number of repetitions."
//         ]
//     },
//     {
//         "bodyPart": "waist",
//         "equipment": "body weight",
//         "gifUrl": "https://v2.exercisedb.io/image/WHA7pERM-oAM-W",
//         "id": "0003",
//         "name": "air bike",
//         "target": "abs",
//         "secondaryMuscles": [
//             "hip flexors"
//         ],
//         "instructions": [
//             "Lie flat on your back with your hands placed behind your head.",
//             "Lift your legs off the ground and bend your knees at a 90-degree angle.",
//             "Bring your right elbow towards your left knee while simultaneously straightening your right leg.",
//             "Return to the starting position and repeat the movement on the opposite side, bringing your left elbow towards your right knee while straightening your left leg.",
//             "Continue alternating sides in a pedaling motion for the desired number of repetitions."
//         ]
//     },
//     {
//         "bodyPart": "waist",
//         "equipment": "body weight",
//         "gifUrl": "https://v2.exercisedb.io/image/9igpaOF9ivN5Xv",
//         "id": "0006",
//         "name": "alternate heel touchers",
//         "target": "abs",
//         "secondaryMuscles": [
//             "obliques"
//         ],
//         "instructions": [
//             "Lie flat on your back with your knees bent and feet flat on the ground.",
//             "Extend your arms straight out to the sides, parallel to the ground.",
//             "Engaging your abs, lift your shoulders off the ground and reach your right hand towards your right heel.",
//             "Return to the starting position and repeat on the left side, reaching your left hand towards your left heel.",
//             "Continue alternating sides for the desired number of repetitions."
//         ]
//     },
//     {
//         "bodyPart": "back",
//         "equipment": "cable",
//         "gifUrl": "https://v2.exercisedb.io/image/Nnfh2-Wyc9oyyZ",
//         "id": "0007",
//         "name": "alternate lateral pulldown",
//         "target": "lats",
//         "secondaryMuscles": [
//             "biceps",
//             "rhomboids"
//         ],
//         "instructions": [
//             "Sit on the cable machine with your back straight and feet flat on the ground.",
//             "Grasp the handles with an overhand grip, slightly wider than shoulder-width apart.",
//             "Lean back slightly and pull the handles towards your chest, squeezing your shoulder blades together.",
//             "Pause for a moment at the peak of the movement, then slowly release the handles back to the starting position.",
//             "Repeat for the desired number of repetitions."
//         ]
//     },
//     {
//         "bodyPart": "chest",
//         "equipment": "leverage machine",
//         "gifUrl": "https://v2.exercisedb.io/image/F5CRFx0GubXS4t",
//         "id": "0009",
//         "name": "assisted chest dip (kneeling)",
//         "target": "pectorals",
//         "secondaryMuscles": [
//             "triceps",
//             "shoulders"
//         ],
//         "instructions": [
//             "Adjust the machine to your desired height and secure your knees on the pad.",
//             "Grasp the handles with your palms facing down and your arms fully extended.",
//             "Lower your body by bending your elbows until your upper arms are parallel to the floor.",
//             "Pause for a moment, then push yourself back up to the starting position.",
//             "Repeat for the desired number of repetitions."
//         ]
//     },
//     {
//         "bodyPart": "waist",
//         "equipment": "assisted",
//         "gifUrl": "https://v2.exercisedb.io/image/s9yGyEahYZaQQF",
//         "id": "0010",
//         "name": "assisted hanging knee raise with throw down",
//         "target": "abs",
//         "secondaryMuscles": [
//             "hip flexors",
//             "lower back"
//         ],
//         "instructions": [
//             "Hang from a pull-up bar with your arms fully extended and your palms facing away from you.",
//             "Engage your core and lift your knees towards your chest, keeping your legs together.",
//             "Once your knees are at chest level, explosively throw your legs down towards the ground, extending them fully.",
//             "Allow your legs to swing back up and repeat the movement for the desired number of repetitions."
//         ]
//     },
//     {
//         "bodyPart": "waist",
//         "equipment": "assisted",
//         "gifUrl": "https://v2.exercisedb.io/image/7u0iIlyM1jYwMa",
//         "id": "0011",
//         "name": "assisted hanging knee raise",
//         "target": "abs",
//         "secondaryMuscles": [
//             "hip flexors"
//         ],
//         "instructions": [
//             "Hang from a pull-up bar with your arms fully extended and your palms facing away from you.",
//             "Engage your core muscles and lift your knees towards your chest, bending at the hips and knees.",
//             "Pause for a moment at the top of the movement, squeezing your abs.",
//             "Slowly lower your legs back down to the starting position.",
//             "Repeat for the desired number of repetitions."
//         ]
//     },
//     {
//         "bodyPart": "waist",
//         "equipment": "assisted",
//         "gifUrl": "https://v2.exercisedb.io/image/9alBnvcroHmLP3",
//         "id": "0012",
//         "name": "assisted lying leg raise with lateral throw down",
//         "target": "abs",
//         "secondaryMuscles": [
//             "hip flexors",
//             "obliques"
//         ],
//         "instructions": [
//             "Lie flat on your back with your legs extended and your arms by your sides.",
//             "Place your hands under your glutes for support.",
//             "Engage your abs and lift your legs off the ground, keeping them straight.",
//             "While keeping your legs together, lower them to one side until they are a few inches above the ground.",
//             "Pause for a moment, then lift your legs back to the starting position.",
//             "Repeat the movement to the other side.",
//             "Continue alternating sides for the desired number of repetitions."
//         ]
//     },
//     {
//         "bodyPart": "waist",
//         "equipment": "assisted",
//         "gifUrl": "https://v2.exercisedb.io/image/Guev5yDM61kA5p",
//         "id": "0013",
//         "name": "assisted lying leg raise with throw down",
//         "target": "abs",
//         "secondaryMuscles": [
//             "hip flexors",
//             "quadriceps"
//         ],
//         "instructions": [
//             "Lie flat on your back with your legs extended and your arms by your sides.",
//             "Place your hands under your glutes for support.",
//             "Engage your core and lift your legs off the ground, keeping them straight.",
//             "Raise your legs until they are perpendicular to the ground.",
//             "Lower your legs back down to the starting position.",
//             "Simultaneously, throw your legs down towards the ground, keeping them straight.",
//             "Raise your legs back up to the starting position.",
//             "Repeat for the desired number of repetitions."
//         ]
//     },
//     {
//         "bodyPart": "waist",
//         "equipment": "medicine ball",
//         "gifUrl": "https://v2.exercisedb.io/image/FxHjx03sa1O4bk",
//         "id": "0014",
//         "name": "assisted motion russian twist",
//         "target": "abs",
//         "secondaryMuscles": [
//             "obliques",
//             "lower back"
//         ],
//         "instructions": [
//             "Sit on the ground with your knees bent and feet flat on the floor.",
//             "Hold the medicine ball with both hands in front of your chest.",
//             "Lean back slightly, engaging your abs and keeping your back straight.",
//             "Slowly twist your torso to the right, bringing the medicine ball towards the right side of your body.",
//             "Pause for a moment, then twist your torso to the left, bringing the medicine ball towards the left side of your body.",
//             "Continue alternating sides for the desired number of repetitions."
//         ]
//     },
//     {
//         "bodyPart": "back",
//         "equipment": "leverage machine",
//         "gifUrl": "https://v2.exercisedb.io/image/WSt0YowXBZUlQf",
//         "id": "0015",
//         "name": "assisted parallel close grip pull-up",
//         "target": "lats",
//         "secondaryMuscles": [
//             "biceps",
//             "forearms"
//         ],
//         "instructions": [
//             "Adjust the machine to your desired weight and height.",
//             "Place your hands on the parallel bars with a close grip, palms facing each other.",
//             "Hang from the bars with your arms fully extended and your feet off the ground.",
//             "Engage your back muscles and pull your body up towards the bars, keeping your elbows close to your body.",
//             "Continue pulling until your chin is above the bars.",
//             "Pause for a moment at the top, then slowly lower your body back down to the starting position.",
//             "Repeat for the desired number of repetitions."
//         ]
//     },
//     {
//         "bodyPart": "upper legs",
//         "equipment": "assisted",
//         "gifUrl": "https://v2.exercisedb.io/image/CAnqdTeucPrqUw",
//         "id": "0016",
//         "name": "assisted prone hamstring",
//         "target": "hamstrings",
//         "secondaryMuscles": [
//             "glutes",
//             "lower back"
//         ],
//         "instructions": [
//             "Lie face down on a mat or bench with your legs fully extended.",
//             "Have a partner or use a resistance band to secure your ankles.",
//             "Engage your hamstrings and lift your legs towards your glutes, keeping your knees straight.",
//             "Pause for a moment at the top, then slowly lower your legs back down to the starting position.",
//             "Repeat for the desired number of repetitions."
//         ]
//     },
//     {
//         "bodyPart": "back",
//         "equipment": "leverage machine",
//         "gifUrl": "https://v2.exercisedb.io/image/oydBwZYH1bR-Ds",
//         "id": "0017",
//         "name": "assisted pull-up",
//         "target": "lats",
//         "secondaryMuscles": [
//             "biceps",
//             "forearms"
//         ],
//         "instructions": [
//             "Adjust the machine to your desired weight and height settings.",
//             "Grasp the handles with an overhand grip, slightly wider than shoulder-width apart.",
//             "Hang with your arms fully extended and your feet off the ground.",
//             "Engage your back muscles and pull your body up towards the handles, keeping your elbows close to your body.",
//             "Continue pulling until your chin is above the handles.",
//             "Pause for a moment at the top, then slowly lower your body back down to the starting position.",
//             "Repeat for the desired number of repetitions."
//         ]
//     },
//     {
//         "bodyPart": "upper arms",
//         "equipment": "assisted",
//         "gifUrl": "https://v2.exercisedb.io/image/5RE4QAJi8fl38W",
//         "id": "0018",
//         "name": "assisted standing triceps extension (with towel)",
//         "target": "triceps",
//         "secondaryMuscles": [
//             "shoulders"
//         ],
//         "instructions": [
//             "Stand with your feet shoulder-width apart and hold a towel with both hands behind your head.",
//             "Keep your elbows close to your ears and your upper arms stationary.",
//             "Slowly extend your forearms upward, squeezing your triceps at the top.",
//             "Pause for a moment, then slowly lower the towel back down to the starting position.",
//             "Repeat for the desired number of repetitions."
//         ]
//     },
//     {
//         "bodyPart": "upper arms",
//         "equipment": "leverage machine",
//         "gifUrl": "https://v2.exercisedb.io/image/fzUeS8f-xpfIZ0",
//         "id": "0019",
//         "name": "assisted triceps dip (kneeling)",
//         "target": "triceps",
//         "secondaryMuscles": [
//             "chest",
//             "shoulders"
//         ],
//         "instructions": [
//             "Adjust the machine to your desired weight and height.",
//             "Kneel down on the pad facing the machine, with your hands gripping the handles.",
//             "Lower your body by bending your elbows, keeping your back straight and close to the machine.",
//             "Pause for a moment at the bottom, then push yourself back up to the starting position.",
//             "Repeat for the desired number of repetitions."
//         ]
//     },
//     {
//         "bodyPart": "upper legs",
//         "equipment": "body weight",
//         "gifUrl": "https://v2.exercisedb.io/image/2k7K7PqrIKC9iA",
//         "id": "0020",
//         "name": "balance board",
//         "target": "quads",
//         "secondaryMuscles": [
//             "calves",
//             "hamstrings",
//             "glutes"
//         ],
//         "instructions": [
//             "Place the balance board on a flat surface.",
//             "Step onto the balance board with one foot, ensuring it is centered.",
//             "Slowly shift your weight onto the foot on the balance board, keeping your core engaged.",
//             "Maintain your balance and stability as you hold the position for a desired amount of time.",
//             "Repeat the exercise with the other foot."
//         ]
//     },
//     {
//         "bodyPart": "back",
//         "equipment": "barbell",
//         "gifUrl": "https://v2.exercisedb.io/image/FSlzxzWG4xXkMt",
//         "id": "0022",
//         "name": "barbell pullover to press",
//         "target": "lats",
//         "secondaryMuscles": [
//             "triceps",
//             "chest",
//             "shoulders"
//         ],
//         "instructions": [
//             "Lie flat on a bench with your head at one end and your feet on the ground.",
//             "Hold the barbell with a pronated grip (palms facing away from you) and extend your arms straight above your chest.",
//             "Keeping your arms straight, lower the barbell behind your head in an arc-like motion until you feel a stretch in your lats.",
//             "Pause for a moment, then reverse the motion and press the barbell back to the starting position above your chest.",
//             "Repeat for the desired number of repetitions."
//         ]
//     },
//     {
//         "bodyPart": "upper arms",
//         "equipment": "barbell",
//         "gifUrl": "https://v2.exercisedb.io/image/DkdYma5LLkaA0V",
//         "id": "0023",
//         "name": "barbell alternate biceps curl",
//         "target": "biceps",
//         "secondaryMuscles": [
//             "forearms"
//         ],
//         "instructions": [
//             "Stand up straight with your feet shoulder-width apart and hold a barbell in each hand, palms facing forward.",
//             "Keep your upper arms stationary and exhale as you curl the weights while contracting your biceps.",
//             "Continue to raise the barbells until your biceps are fully contracted and the barbells are at shoulder level.",
//             "Hold the contracted position for a brief pause as you squeeze your biceps.",
//             "Inhale as you slowly begin to lower the barbells back to the starting position.",
//             "Repeat for the desired number of repetitions, alternating arms."
//         ]
//     },
//     {
//         "bodyPart": "upper legs",
//         "equipment": "barbell",
//         "gifUrl": "https://v2.exercisedb.io/image/vvR81xpAg4CWJ2",
//         "id": "0024",
//         "name": "barbell bench front squat",
//         "target": "quads",
//         "secondaryMuscles": [
//             "hamstrings",
//             "glutes",
//             "calves"
//         ],
//         "instructions": [
//             "Start by standing with your feet shoulder-width apart and the barbell resting on your upper chest, just below your collarbone.",
//             "Hold the barbell with an overhand grip, keeping your elbows up and your upper arms parallel to the ground.",
//             "Lower your body down into a squat position by bending at the knees and hips, keeping your back straight and your chest up.",
//             "Pause for a moment at the bottom of the squat, then push through your heels to return to the starting position.",
//             "Repeat for the desired number of repetitions."
//         ]
//     },
//     {
//         "bodyPart": "chest",
//         "equipment": "barbell",
//         "gifUrl": "https://v2.exercisedb.io/image/tiOSZIsQyZizyR",
//         "id": "0025",
//         "name": "barbell bench press",
//         "target": "pectorals",
//         "secondaryMuscles": [
//             "triceps",
//             "shoulders"
//         ],
//         "instructions": [
//             "Lie flat on a bench with your feet flat on the ground and your back pressed against the bench.",
//             "Grasp the barbell with an overhand grip slightly wider than shoulder-width apart.",
//             "Lift the barbell off the rack and hold it directly above your chest with your arms fully extended.",
//             "Lower the barbell slowly towards your chest, keeping your elbows tucked in.",
//             "Pause for a moment when the barbell touches your chest.",
//             "Push the barbell back up to the starting position by extending your arms.",
//             "Repeat for the desired number of repetitions."
//         ]
//     },
//     {
//         "bodyPart": "upper legs",
//         "equipment": "barbell",
//         "gifUrl": "https://v2.exercisedb.io/image/Iqzgr6KhymiYI4",
//         "id": "0026",
//         "name": "barbell bench squat",
//         "target": "quads",
//         "secondaryMuscles": [
//             "glutes",
//             "hamstrings",
//             "calves"
//         ],
//         "instructions": [
//             "Set up a barbell on a squat rack at chest height.",
//             "Stand facing away from the rack, with your feet shoulder-width apart.",
//             "Bend your knees and lower your body down into a squat position, keeping your back straight and chest up.",
//             "Grasp the barbell with an overhand grip, slightly wider than shoulder-width apart.",
//             "Lift the barbell off the rack and step back, ensuring your feet are still shoulder-width apart.",
//             "Lower your body down into a squat, keeping your knees in line with your toes.",
//             "Pause for a moment at the bottom, then push through your heels to return to the starting position.",
//             "Repeat for the desired number of repetitions."
//         ]
//     },
//     {
//         "bodyPart": "back",
//         "equipment": "barbell",
//         "gifUrl": "https://v2.exercisedb.io/image/iZ4Eap8FQDL8f6",
//         "id": "0027",
//         "name": "barbell bent over row",
//         "target": "upper back",
//         "secondaryMuscles": [
//             "biceps",
//             "forearms"
//         ],
//         "instructions": [
//             "Stand with your feet shoulder-width apart and knees slightly bent.",
//             "Bend forward at the hips while keeping your back straight and chest up.",
//             "Grasp the barbell with an overhand grip, hands slightly wider than shoulder-width apart.",
//             "Pull the barbell towards your lower chest by retracting your shoulder blades and squeezing your back muscles.",
//             "Pause for a moment at the top, then slowly lower the barbell back to the starting position.",
//             "Repeat for the desired number of repetitions."
//         ]
//     },
//     {
//         "bodyPart": "upper legs",
//         "equipment": "barbell",
//         "gifUrl": "https://v2.exercisedb.io/image/k6Q2jtPlyhVKNd",
//         "id": "0028",
//         "name": "barbell clean and press",
//         "target": "quads",
//         "secondaryMuscles": [
//             "hamstrings",
//             "glutes",
//             "shoulders",
//             "triceps"
//         ],
//         "instructions": [
//             "Stand with your feet shoulder-width apart and the barbell on the floor in front of you.",
//             "Bend your knees and hinge at the hips to lower down and grip the barbell with an overhand grip, hands slightly wider than shoulder-width apart.",
//             "Drive through your heels and extend your hips and knees to lift the barbell off the floor, keeping it close to your body.",
//             "As the barbell reaches your thighs, explosively extend your hips, shrug your shoulders, and pull the barbell up towards your chest.",
//             "As the barbell reaches chest height, quickly drop under it and catch it at shoulder level, with your elbows pointing forward and your palms facing up.",
//             "From the catch position, press the barbell overhead by extending your arms and pushing the barbell straight up.",
//             "Lower the barbell back down to the starting position and repeat for the desired number of repetitions."
//         ]
//     },
//     {
//         "bodyPart": "upper legs",
//         "equipment": "barbell",
//         "gifUrl": "https://v2.exercisedb.io/image/MCXdoaTFW1Q1dR",
//         "id": "0029",
//         "name": "barbell clean-grip front squat",
//         "target": "glutes",
//         "secondaryMuscles": [
//             "quadriceps",
//             "hamstrings",
//             "calves",
//             "core"
//         ],
//         "instructions": [
//             "Start by standing with your feet shoulder-width apart and the barbell resting on your upper chest, with your elbows pointing forward.",
//             "Lower your body by bending your knees and pushing your hips back, as if you are sitting back into a chair.",
//             "Keep your chest up and your back straight as you lower down, making sure your knees do not go past your toes.",
//             "Continue lowering until your thighs are parallel to the ground, or as low as you can comfortably go.",
//             "Pause for a moment at the bottom, then push through your heels to stand back up, extending your hips and knees.",
//             "Repeat for the desired number of repetitions."
//         ]
//     },
//     {
//         "bodyPart": "upper arms",
//         "equipment": "barbell",
//         "gifUrl": "https://v2.exercisedb.io/image/LW496xxQinAOYu",
//         "id": "0030",
//         "name": "barbell close-grip bench press",
//         "target": "triceps",
//         "secondaryMuscles": [
//             "chest",
//             "shoulders"
//         ],
//         "instructions": [
//             "Lie flat on a bench with your feet flat on the ground and your back pressed against the bench.",
//             "Grasp the barbell with a close grip, slightly narrower than shoulder-width apart.",
//             "Unrack the barbell and lower it slowly towards your chest, keeping your elbows close to your body.",
//             "Pause for a moment when the barbell touches your chest.",
//             "Push the barbell back up to the starting position, fully extending your arms.",
//             "Repeat for the desired number of repetitions."
//         ]
//     },
//     {
//         "bodyPart": "upper arms",
//         "equipment": "barbell",
//         "gifUrl": "https://v2.exercisedb.io/image/m784gCy9Hu4qW8",
//         "id": "0031",
//         "name": "barbell curl",
//         "target": "biceps",
//         "secondaryMuscles": [
//             "forearms"
//         ],
//         "instructions": [
//             "Stand up straight with your feet shoulder-width apart and hold a barbell with an underhand grip, palms facing forward.",
//             "Keep your elbows close to your torso and exhale as you curl the weights while contracting your biceps.",
//             "Continue to raise the bar until your biceps are fully contracted and the bar is at shoulder level.",
//             "Hold the contracted position for a brief pause as you squeeze your biceps.",
//             "Inhale as you slowly begin to lower the bar back to the starting position.",
//             "Repeat for the desired number of repetitions."
//         ]
//     },
//     {
//         "bodyPart": "upper legs",
//         "equipment": "barbell",
//         "gifUrl": "https://v2.exercisedb.io/image/h6UqSpQhXNByGg",
//         "id": "0032",
//         "name": "barbell deadlift",
//         "target": "glutes",
//         "secondaryMuscles": [
//             "hamstrings",
//             "lower back"
//         ],
//         "instructions": [
//             "Stand with your feet shoulder-width apart and the barbell on the ground in front of you.",
//             "Bend your knees and hinge at the hips to lower your torso and grip the barbell with an overhand grip, hands slightly wider than shoulder-width apart.",
//             "Keep your back straight and chest lifted as you drive through your heels to lift the barbell off the ground, extending your hips and knees.",
//             "As you stand up straight, squeeze your glutes and keep your core engaged.",
//             "Lower the barbell back down to the ground by bending at the hips and knees, keeping your back straight.",
//             "Repeat for the desired number of repetitions."
//         ]
//     },
//     {
//         "bodyPart": "chest",
//         "equipment": "barbell",
//         "gifUrl": "https://v2.exercisedb.io/image/WHe-EvBiHM99K5",
//         "id": "0033",
//         "name": "barbell decline bench press",
//         "target": "pectorals",
//         "secondaryMuscles": [
//             "triceps",
//             "shoulders"
//         ],
//         "instructions": [
//             "Lie on a decline bench with your feet secured and your head lower than your hips.",
//             "Grasp the barbell with an overhand grip slightly wider than shoulder-width apart.",
//             "Unrack the barbell and lower it slowly towards your chest, keeping your elbows tucked in.",
//             "Pause for a moment at the bottom, then push the barbell back up to the starting position.",
//             "Repeat for the desired number of repetitions."
//         ]
//     },
//     {
//         "bodyPart": "back",
//         "equipment": "barbell",
//         "gifUrl": "https://v2.exercisedb.io/image/ncHl4oBp77mb8q",
//         "id": "0034",
//         "name": "barbell decline bent arm pullover",
//         "target": "lats",
//         "secondaryMuscles": [
//             "triceps",
//             "chest"
//         ],
//         "instructions": [
//             "Lie down on a decline bench with your head lower than your hips and your feet secured.",
//             "Hold a barbell with a pronated grip (palms facing away from you) and extend your arms straight above your chest.",
//             "Lower the barbell behind your head in a controlled manner, keeping your arms slightly bent.",
//             "Pause for a moment, then raise the barbell back to the starting position by contracting your lats.",
//             "Repeat for the desired number of repetitions."
//         ]
//     }
// ]
// ];