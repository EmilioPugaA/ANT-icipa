// src/patterns.ts
export interface MerchantPattern {
  category: string;
  patterns: string[];
  keywords: string[];
  examples: string[];
}

export const MERCHANT_CATEGORIES: Record<string, MerchantPattern> = {
  gasto_hormiga: {
    category: "Gasto Hormiga",
    patterns: [
      "oxxo",
      "seven",
      "7-eleven",
      "7eleven",
      "extra",
      "kiosko",
      "tiendita",
      "minisuper",
      "starbucks",
      "Tim Hortons"
    ],
    keywords: [
      "dulces",
      "snacks",
      "refresco",
      "cigarros",
      "botanas",
      "golosinas"
    ],
    examples: [
      "OXXO CENTRALES TEC",
      "SEVEN ELEVEN GARZA SADA",
      "EXTRA VALLE ORIENTE"
    ]
  },
  transporte: {
    category: "Transporte",
    patterns: [
      "uber",
      "didi",
      "cabify",
      "metrorrey",
      "ecobici",
      "gasolina",
      "pemex",
      "shell"
    ],
    keywords: ["viaje", "transporte", "taxi", "combustible"],
    examples: [
      "UBER *TRIP",
      "DIDI MEXICO",
      "GASOLINA PEMEX"
    ]
  },
  alimentacion: {
    category: "Alimentación",
    patterns: [
      "mcdonalds",
      "burger",
      "subway",
      "dominos",
      "pizza",
      "restaurante",
      "taqueria",
      "tacos"
    ],
    keywords: ["comida", "restaurante", "cafe", "food"],
    examples: [
      "MCDONALDS INSURGENTES",
      "TACOS DON JULIO"
    ]
  },
  supermercado: {
    category: "Supermercado",
    patterns: [
      "soriana",
      "heb",
      "walmart",
      "costco",
      "sams",
      "chedraui",
      "comercial mexicana"
    ],
    keywords: ["super", "mercado", "despensa", "abarrotes"],
    examples: [
      "HEB VALLE ORIENTE",
      "WALMART GARZA SADA",
      "COSTCO APODACA"
    ]
  },
  entretenimiento: {
    category: "Entretenimiento",
    patterns: [
      "cinepolis",
      "cinemex",
      "spotify",
      "netflix",
      "hbo",
      "disney",
      "prime video",
      "xbox",
      "playstation"
    ],
    keywords: ["cine", "streaming", "juegos", "entretenimiento"],
    examples: [
      "CINEPOLIS GALERIAS",
      "SPOTIFY PREMIUM",
      "NETFLIX.COM"
    ]
  },
  educacion: {
    category: "Educación",
    patterns: [
      "libreria",
      "amazon",
      "gandhi",
      "porrua",
      "office depot",
      "colegiatura",
      "udemy",
      "coursera"
    ],
    keywords: ["libros", "materiales", "papeleria", "curso"],
    examples: [
      "LIBRERIA GANDHI",
      "OFFICE DEPOT TEC",
      "UDEMY COURSE"
    ]
  }
};

export function detectCategory(description: string): {
  category: string;
  confidence: number;
  matchedPattern: string;
} | null {
  const descLower = description.toLowerCase();
  
  for (const [key, pattern] of Object.entries(MERCHANT_CATEGORIES)) {
    // Buscar coincidencias en patterns
    for (const p of pattern.patterns) {
      if (descLower.includes(p.toLowerCase())) {
        return {
          category: pattern.category,
          confidence: 95,
          matchedPattern: p
        };
      }
    }
    
    // Buscar coincidencias en keywords (menor confianza)
    for (const keyword of pattern.keywords) {
      if (descLower.includes(keyword.toLowerCase())) {
        return {
          category: pattern.category,
          confidence: 75,
          matchedPattern: keyword
        };
      }
    }
  }
  
  return null;
}
