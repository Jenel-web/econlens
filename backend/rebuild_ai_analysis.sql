-- 1. Wipe out and drop the existing table
DROP TABLE IF EXISTS public.ai_analysis;

-- 2. Rebuild the table with the exact new schema
CREATE TABLE public.ai_analysis (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    article_id UUID NOT NULL REFERENCES public.articles(id) ON DELETE CASCADE,
    ano_ang_nangyari TEXT NOT NULL,
    paano_ito_makakaapekto_satin TEXT NOT NULL,
    advice TEXT NOT NULL,
    tinatantyang_epekto_sa_budget TEXT NOT NULL,
    apektadong_larangan TEXT NOT NULL,
    severity_level TEXT NOT NULL CHECK (severity_level IN ('low', 'medium', 'high')),
    generated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. Create index for performance
CREATE INDEX IF NOT EXISTS idx_ai_analysis_article_id ON public.ai_analysis(article_id);
