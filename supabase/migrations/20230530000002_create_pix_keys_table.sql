-- Cria a tabela de chaves PIX
CREATE TABLE IF NOT EXISTS public.pix_keys (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  key_type TEXT NOT NULL CHECK (key_type IN ('CPF', 'E-mail', 'Telefone', 'Chave Aleatória')),
  key_value TEXT NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT unique_active_key_per_user UNIQUE (user_id, key_value, is_active) DEFERRABLE INITIALLY DEFERRED
);

-- Cria um índice para melhorar a busca por chaves ativas
CREATE INDEX IF NOT EXISTS idx_pix_keys_key_value_is_active ON public.pix_keys(key_value, is_active);

-- Cria um gatilho para atualizar o campo updated_at automaticamente
CREATE OR REPLACE FUNCTION update_pix_key_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_pix_key_updated_at
BEFORE UPDATE ON public.pix_keys
FOR EACH ROW
EXECUTE FUNCTION update_pix_key_updated_at();

-- Adiciona permissões
ALTER TABLE public.pix_keys ENABLE ROW LEVEL SECURITY;

-- Políticas de segurança
CREATE POLICY "Permitir leitura das próprias chaves PIX"
  ON public.pix_keys
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Permitir inserção de chaves PIX para usuários autenticados"
  ON public.pix_keys
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Permitir atualização das próprias chaves PIX"
  ON public.pix_keys
  FOR UPDATE
  USING (auth.uid() = user_id);

-- Comentários para documentação
COMMENT ON TABLE public.pix_keys IS 'Armazena as chaves PIX dos usuários';
COMMENT ON COLUMN public.pix_keys.key_type IS 'Tipo da chave PIX (CPF, E-mail, Telefone, Chave Aleatória)';
COMMENT ON COLUMN public.pix_keys.key_value IS 'Valor da chave PIX';
COMMENT ON COLUMN public.pix_keys.is_active IS 'Indica se a chave está ativa';

-- Adiciona uma restrição para garantir que apenas uma chave ativa por tipo por usuário
-- (opcional, descomente se necessário)
-- ALTER TABLE public.pix_keys
-- ADD CONSTRAINT one_active_key_per_type_per_user
-- EXCLUDE USING btree (user_id WITH =, key_type WITH =) WHERE (is_active);
