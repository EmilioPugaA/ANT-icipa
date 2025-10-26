//
//  TransactionCard.swift
//  ANTicipa
//
//  Created by Enmanuel Rivas Barinas on 10/25/25.
//

import SwiftUI

struct TransactionCard: View {
    let transaction: TransactionWithCategory
    
    var body: some View {
        HStack {
            Image(systemName: transaction.is_gasto_hormiga == 1 ? "leaf.fill" : "creditcard")
                .foregroundColor(transaction.is_gasto_hormiga == 1 ? .yellow : .gray)
                .font(.title2)
                .padding(8)
                .background(Color.white)
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(transaction.category ?? "Sin categoría")
                    .font(.headline)
                if let fecha = transactionDateFormatted {
                    Text(fecha)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            Text(String(format: "$%.2f", transaction.montoDouble))
                .foregroundColor(transaction.is_gasto_hormiga == 1 ? .yellow : .primary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    // MARK: - Formato de fecha legible
    private var transactionDateFormatted: String? {
        guard let raw = transaction.fecha_hora_transaccion else { return nil }
        // Ejemplo: "Sat, 25 Oct 2025 15:40:47 GMT"
        let formatter = DateFormatter()
        formatter.dateFormat = "E, dd MMM yyyy HH:mm:ss zzz"
        if let date = formatter.date(from: raw) {
            let output = DateFormatter()
            output.locale = Locale(identifier: "es_MX")
            output.dateFormat = "dd MMM yyyy, HH:mm"
            return output.string(from: date)
        }
        return nil
    }
}

#Preview {
    // Ejemplo de transacción simulada con tu modelo real del API
    let mockTransaction = TransactionWithCategory(
        id_transaccion: 6,
        id_cliente: 1,
        monto: "-85.00",
        category: "Alimentación",
        is_gasto_hormiga: 1,
        auto_categorized: 1,
        suggestions: ["Moderado, dentro de lo normal"],
        balance_resultante: "390.00",
        category_confidence: "95.00",
        tipo_categoria: "Débito",
        tipo_descripcion: "Compra con tarjeta",
        fecha_hora_transaccion: "Sat, 25 Oct 2025 15:40:47 GMT"
    )

    ZStack {
        Color.white.ignoresSafeArea()
        TransactionCard(transaction: mockTransaction)
            .padding()
    }
}
