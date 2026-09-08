import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'Legacy Evolution — 実物で辿るシステム進化',
  description: '要件・制約・設計・COBOL・テストを実物で辿るローカルデモ',
};

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="ja">
      <body>{children}</body>
    </html>
  );
}

