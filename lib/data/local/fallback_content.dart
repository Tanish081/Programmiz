const Map<String, dynamic> kFallbackPythonRoadmap = {
  'estimatedDays': 45,
  'aiSummary': 'This offline Python roadmap keeps your momentum going even without internet.',
  'phases': [
    {
      'phaseTitle': 'Phase 1: Foundations',
      'description': 'Core syntax and problem-solving basics.',
      'estimatedDays': 10,
      'emoji': '🌱',
      'topics': [
        {
          'topicId': 'py_001',
          'title': 'Variables and Data Types',
          'description': 'Understand numbers, strings, booleans, and lists.',
          'difficulty': 'easy',
          'estimatedMinutes': 20,
          'keyPoints': ['Type basics', 'Casting', 'Common pitfalls']
        },
        {
          'topicId': 'py_002',
          'title': 'Conditionals',
          'description': 'Control flow with if, elif, else.',
          'difficulty': 'easy',
          'estimatedMinutes': 20,
          'keyPoints': ['Boolean logic', 'Nesting', 'Readable branching']
        },
        {
          'topicId': 'py_003',
          'title': 'Loops',
          'description': 'Repeat tasks with for and while loops.',
          'difficulty': 'easy',
          'estimatedMinutes': 25,
          'keyPoints': ['Loop control', 'Ranges', 'Loop patterns']
        }
      ]
    },
    {
      'phaseTitle': 'Phase 2: Functions and Data',
      'description': 'Write reusable code and organize data.',
      'estimatedDays': 12,
      'emoji': '🧩',
      'topics': [
        {
          'topicId': 'py_004',
          'title': 'Functions',
          'description': 'Build modular reusable logic.',
          'difficulty': 'easy',
          'estimatedMinutes': 25,
          'keyPoints': ['Parameters', 'Return values', 'Scope']
        },
        {
          'topicId': 'py_005',
          'title': 'Dictionaries and Sets',
          'description': 'Model keyed and unique data.',
          'difficulty': 'medium',
          'estimatedMinutes': 25,
          'keyPoints': ['CRUD operations', 'Membership', 'Iteration']
        },
        {
          'topicId': 'py_006',
          'title': 'Comprehensions',
          'description': 'Create concise transformations.',
          'difficulty': 'medium',
          'estimatedMinutes': 20,
          'keyPoints': ['List comprehensions', 'Filters', 'Readability']
        }
      ]
    },
    {
      'phaseTitle': 'Phase 3: Real-World Python',
      'description': 'Handle files, errors, and modules.',
      'estimatedDays': 11,
      'emoji': '🛠',
      'topics': [
        {
          'topicId': 'py_007',
          'title': 'File I/O',
          'description': 'Read and write files safely.',
          'difficulty': 'medium',
          'estimatedMinutes': 30,
          'keyPoints': ['with context', 'Path handling', 'CSV basics']
        },
        {
          'topicId': 'py_008',
          'title': 'Error Handling',
          'description': 'Use try/except to write resilient code.',
          'difficulty': 'medium',
          'estimatedMinutes': 25,
          'keyPoints': ['Exception hierarchy', 'Custom errors', 'Best practices']
        },
        {
          'topicId': 'py_009',
          'title': 'Modules and Packages',
          'description': 'Structure and import code effectively.',
          'difficulty': 'medium',
          'estimatedMinutes': 20,
          'keyPoints': ['Imports', 'Package layout', 'Virtual environments']
        }
      ]
    },
    {
      'phaseTitle': 'Phase 4: Advanced Foundations',
      'description': 'Object-oriented patterns and interview prep.',
      'estimatedDays': 12,
      'emoji': '🚀',
      'topics': [
        {
          'topicId': 'py_010',
          'title': 'Object-Oriented Programming',
          'description': 'Build classes and reusable abstractions.',
          'difficulty': 'medium',
          'estimatedMinutes': 35,
          'keyPoints': ['Classes', 'Inheritance', 'Encapsulation']
        },
        {
          'topicId': 'py_011',
          'title': 'Testing Basics',
          'description': 'Write unit tests for confidence.',
          'difficulty': 'medium',
          'estimatedMinutes': 25,
          'keyPoints': ['Assertions', 'Arrange-act-assert', 'Edge cases']
        },
        {
          'topicId': 'py_012',
          'title': 'Interview Drills',
          'description': 'Practice coding and conceptual questions.',
          'difficulty': 'hard',
          'estimatedMinutes': 30,
          'keyPoints': ['Time complexity', 'Debugging', 'Communication']
        }
      ]
    }
  ]
};

const List<Map<String, dynamic>> kFallbackInterviewQuestions = [
  {
    'questionId': 'f_q001',
    'questionText': 'What is the difference between a list and a tuple in Python?',
    'type': 'mcq',
    'difficulty': 'easy',
    'options': ['Tuples are mutable', 'Lists are immutable', 'Lists are mutable', 'No difference'],
    'correctAnswer': 'Lists are mutable',
    'sampleAnswer': null,
  },
  {
    'questionId': 'f_q002',
    'questionText': 'Explain how Python memory management works.',
    'type': 'open_ended',
    'difficulty': 'medium',
    'options': null,
    'correctAnswer': null,
    'sampleAnswer': 'Python uses reference counting and garbage collection to reclaim unused memory.',
  },
  {
    'questionId': 'f_q003',
    'questionText': 'Review this code and identify the bug: for i in range(len(items)): print(items[i+1])',
    'type': 'code_review',
    'difficulty': 'medium',
    'options': null,
    'correctAnswer': null,
    'sampleAnswer': 'It can access out-of-range index. Use items[i] or iterate directly over items.',
  },
  {
    'questionId': 'f_q004',
    'questionText': 'What does Big O notation describe?',
    'type': 'mcq',
    'difficulty': 'medium',
    'options': ['Memory address', 'Algorithmic complexity', 'Syntax rules', 'Code style'],
    'correctAnswer': 'Algorithmic complexity',
    'sampleAnswer': null,
  },
  {
    'questionId': 'f_q005',
    'questionText': 'Describe the use of try/except/finally in Python.',
    'type': 'open_ended',
    'difficulty': 'easy',
    'options': null,
    'correctAnswer': null,
    'sampleAnswer': 'Use try for risky code, except for handling errors, and finally for cleanup.',
  },
];

const List<Map<String, dynamic>> kFallbackDomainRoadmaps = [
  {
    'domainId': 'fullstack',
    'estimatedDays': 120,
    'aiSummary': 'Offline full stack roadmap to build frontend + backend job readiness.',
    'phases': [
      {'phaseTitle': 'Phase 1: Web Basics', 'description': 'HTML/CSS/JS fundamentals', 'estimatedDays': 25, 'emoji': '🌱', 'topics': []},
      {'phaseTitle': 'Phase 2: Frontend Apps', 'description': 'React and UI architecture', 'estimatedDays': 30, 'emoji': '🧩', 'topics': []},
      {'phaseTitle': 'Phase 3: Backend APIs', 'description': 'Node, auth, data models', 'estimatedDays': 35, 'emoji': '🛠', 'topics': []},
      {'phaseTitle': 'Phase 4: Deploy and Scale', 'description': 'Testing and deployment', 'estimatedDays': 30, 'emoji': '🚀', 'topics': []},
    ]
  },
  {
    'domainId': 'data_analyst',
    'estimatedDays': 100,
    'aiSummary': 'Offline data analyst roadmap focused on practical analysis workflows.',
    'phases': [
      {'phaseTitle': 'Phase 1: Python and SQL', 'description': 'Foundational data skills', 'estimatedDays': 22, 'emoji': '🌱', 'topics': []},
      {'phaseTitle': 'Phase 2: Data Wrangling', 'description': 'Pandas and cleaning', 'estimatedDays': 26, 'emoji': '🧩', 'topics': []},
      {'phaseTitle': 'Phase 3: Visualization', 'description': 'Storytelling with charts', 'estimatedDays': 24, 'emoji': '📊', 'topics': []},
      {'phaseTitle': 'Phase 4: Portfolio Projects', 'description': 'Business case studies', 'estimatedDays': 28, 'emoji': '🚀', 'topics': []},
    ]
  },
  {
    'domainId': 'ml_ai',
    'estimatedDays': 140,
    'aiSummary': 'Offline AI roadmap from statistics to practical model deployment.',
    'phases': [
      {'phaseTitle': 'Phase 1: Math and Python', 'description': 'Linear algebra and coding', 'estimatedDays': 30, 'emoji': '🌱', 'topics': []},
      {'phaseTitle': 'Phase 2: Classical ML', 'description': 'Regression and classification', 'estimatedDays': 36, 'emoji': '🤖', 'topics': []},
      {'phaseTitle': 'Phase 3: Deep Learning', 'description': 'Neural network basics', 'estimatedDays': 38, 'emoji': '🧠', 'topics': []},
      {'phaseTitle': 'Phase 4: MLOps', 'description': 'Experiment tracking and serving', 'estimatedDays': 36, 'emoji': '🚀', 'topics': []},
    ]
  },
  {
    'domainId': 'android_dev',
    'estimatedDays': 120,
    'aiSummary': 'Offline mobile roadmap from UI basics to production releases.',
    'phases': [
      {'phaseTitle': 'Phase 1: Mobile Foundations', 'description': 'Dart/Kotlin and architecture', 'estimatedDays': 24, 'emoji': '🌱', 'topics': []},
      {'phaseTitle': 'Phase 2: App Features', 'description': 'State, navigation, persistence', 'estimatedDays': 30, 'emoji': '📱', 'topics': []},
      {'phaseTitle': 'Phase 3: Backend Integration', 'description': 'APIs and auth', 'estimatedDays': 34, 'emoji': '🛠', 'topics': []},
      {'phaseTitle': 'Phase 4: Publish', 'description': 'Testing and deployment', 'estimatedDays': 32, 'emoji': '🚀', 'topics': []},
    ]
  },
  {
    'domainId': 'cybersecurity',
    'estimatedDays': 130,
    'aiSummary': 'Offline security roadmap for defense, testing, and incident response.',
    'phases': [
      {'phaseTitle': 'Phase 1: Security Basics', 'description': 'Linux, networking, threat models', 'estimatedDays': 28, 'emoji': '🌱', 'topics': []},
      {'phaseTitle': 'Phase 2: Defensive Security', 'description': 'Hardening and monitoring', 'estimatedDays': 32, 'emoji': '🔒', 'topics': []},
      {'phaseTitle': 'Phase 3: Ethical Hacking', 'description': 'Pentest process and tools', 'estimatedDays': 36, 'emoji': '🛠', 'topics': []},
      {'phaseTitle': 'Phase 4: Incident Response', 'description': 'Detection and response', 'estimatedDays': 34, 'emoji': '🚀', 'topics': []},
    ]
  },
];
