// src/index.ts
import dotenv from 'dotenv';
dotenv.config();
import express from 'express';
import { TransactionCategorizer } from './categorizer';




const app = express();
app.use(express.json());

const categorizer = new TransactionCategorizer(process.env.ANTHROPIC_API_KEY || '');


app.post('/categorize', async (req, res) => {
  try {
    const { description, amount, date } = req.body;

    if (!description) {
      return res.status(400).json({
        error: 'Description is required'
      });
    }

    const result = await categorizer.categorize({
      description,
      amount: amount || 0,
      date
    });

    res.json({
      success: true,
      transaction: { description, amount, date },
      categorization: result
    });
  } catch (error: any) {
    console.error('Categorization error:', error);
    res.status(500).json({
      error: 'Failed to categorize transaction',
      message: error.message
    });
  }
});

app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'ANTicipa Categorizer' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 ANTicipa Categorizer running on port ${PORT}`);
});
