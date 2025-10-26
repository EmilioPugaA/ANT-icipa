// src/categorizer.ts
import Anthropic from "@anthropic-ai/sdk";
import { MERCHANT_CATEGORIES, detectCategory } from "./patterns";

interface Transaction {
  description: string;
  amount: number;
  date?: string;
}

interface CategorizationResult {
  category: string;
  confidence: number;
  reasoning: string;
  isGastoHormiga: boolean;
  suggestions?: string[];
}

export class TransactionCategorizer {
  private client: Anthropic;

  constructor(apiKey: string) {
    this.client = new Anthropic({ apiKey });
  }

  async categorize(transaction: Transaction): Promise<CategorizationResult> {
    // Primero intentar categorización rápida con patrones
    const quickMatch = detectCategory(transaction.description);
    if (quickMatch && quickMatch.confidence >= 90) {
      console.log("Coincidencia rápida encontrada:", quickMatch);
      return {
        category: quickMatch.category,
        confidence: quickMatch.confidence,
        reasoning: `Coincidencia directa con patrón: ${quickMatch.matchedPattern}`,
        isGastoHormiga: quickMatch.category === "Gasto Hormiga",
        suggestions: this.getSuggestions(quickMatch.category, transaction.amount)
      };
    }

    console.log("No se encontró coincidencia rápida, consultando Anthropic...");
    return await this.categorizeWithAI(transaction);
  }

  private async categorizeWithAI(transaction: Transaction): Promise<CategorizationResult> {
    const prompt = this.buildPrompt(transaction);
    console.log("Prompt enviado a Anthropic:", prompt);

    const response = await this.client.messages.create({
      model: "claude-v1", // modelo actualizado
      max_tokens: 500,
      messages: [{
        role: "user",
        content: prompt
      }]
    });

    console.log("Respuesta cruda de Anthropic:", response);

    const content = response.content[0];
    if (!content || content.type !== "text") {
      throw new Error("Unexpected response type");
    }

    const result = JSON.parse(content.text);
    console.log("Resultado parseado:", result);

    return {
      category: result.category,
      confidence: result.confidence,
      reasoning: result.reasoning,
      isGastoHormiga: result.category === "Gasto Hormiga",
      suggestions: result.suggestions || []
    };
  }

  private buildPrompt(transaction: Transaction): string {
    const categoriesInfo = Object.entries(MERCHANT_CATEGORIES)
      .map(([key, pattern]) => {
        return `- ${pattern.category}: ${pattern.patterns.slice(0, 5).join(", ")}`;
      })
      .join("\n");

    return `Eres un experto en categorización de gastos financieros para estudiantes mexicanos del Tec de Monterrey.

CATEGORÍAS DISPONIBLES:
${categoriesInfo}

TRANSACCIÓN A ANALIZAR:
- Descripción: "${transaction.description}"
- Monto: $${transaction.amount} MXN
${transaction.date ? `- Fecha: ${transaction.date}` : ''}

IMPORTANTE:
- "Gasto Hormiga" son compras pequeñas y frecuentes en tiendas de conveniencia (OXXO, Seven, etc.) que suelen ser innecesarias
- Si el comercio es OXXO, Seven Eleven, o tienda de conveniencia → es "Gasto Hormiga"
- Considera el contexto mexicano y comercios locales de Monterrey

Responde ÚNICAMENTE con un JSON válido (sin markdown ni código adicional):
{
  "category": "nombre_categoria",
  "confidence": 85,
  "reasoning": "explicación de por qué esta categoría",
  "suggestions": ["sugerencia 1", "sugerencia 2"]
}`;
  }

  private getSuggestions(category: string, amount: number): string[] {
    const suggestions: Record<string, string[]> = {
      "Gasto Hormiga": [
        "Considera preparar snacks en casa para ahorrar",
        "Lleva una botella de agua reutilizable",
        "Establece un presupuesto semanal para este tipo de gastos"
      ],
      "Transporte": [
        "Evalúa usar transporte público si es posible",
        "Considera compartir viajes con compañeros",
        "Revisa si tu ruta puede hacerse en bicicleta"
      ],
      "Alimentación": [
        amount > 200 ? "Este gasto parece alto, considera cocinar en casa" : "Moderado, dentro de lo normal",
        "Planifica tus comidas semanalmente"
      ]
    };

    return suggestions[category] || ["Mantén un registro de estos gastos"];
  }
}
