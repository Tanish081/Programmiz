// Get free API key at console.groq.com
const String kGroqApiKey = String.fromEnvironment(
	'GROQ_API_KEY',
	defaultValue: '',
);
const String kGroqBaseUrl = 'https://api.groq.com/openai/v1/chat/completions';
