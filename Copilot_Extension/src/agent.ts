import Anthropic from "@anthropic-ai/sdk";

interface Transaction {
  description: string;
  amount: number;
  merchant?: string;
}

interface CategorizationResult {
  category: string;
  confidence: number;
  reasoning: string;
}

export async function categorizeTransaction(
  transaction: Transaction
): Promise<CategorizationResult> {
  
  const prompt = `
  Eres un experto en categorización de gastos financieros para estudiantes mexicanos.
  
  PATRONES CONOCIDOS:
  - Gasto Hormiga: OXXO, Seven Eleven, tienditas, dulcerías, snacks, refrescos, Starbucks, Tim, Hortons, Laurel, Bread, Cafeterias
  - Transporte: Uber, DiDi, Cabify, Metrorrey, gasolina
  - Alimentación: Restaurantes, comida rápida
  - Necesidades: Supermercados grandes, farmacia, servicios básicos
  - Educación: Libros, materiales escolares, colegiaturas
  
  TRANSACCIÓN A ANALIZAR:
  Descripción: "${transaction.description}"
  Monto: $${transaction.amount}
  
  Determina:
  1. Categoría principal
  2. Nivel de confianza (0-100)
  3. Razón de la clasificación
  
  Responde en formato JSON:
  {
    "category": "nombre_categoria",
    "confidence": 95,
    "reasoning": "explicación breve"
  }
  `;

  // Aquí integrarías con Copilot/Claude
  const client = new Anthropic({
    apiKey: process.env.ANTHROPIC_API_KEY
  });

  const response = await client.messages.create({
    model: "claude-3-5-sonnet-20241022",
    max_tokens: 5,
    messages: [{
      role: "user",
      content: prompt
    }]
  });

  return JSON.parse(response.content[0].text);
}
