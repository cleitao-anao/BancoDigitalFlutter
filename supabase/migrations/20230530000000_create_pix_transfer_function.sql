-- Função para realizar transferência PIX
CREATE OR REPLACE FUNCTION public.make_pix_transfer(
  p_sender_id uuid,
  p_pix_key text,
  p_amount decimal,
  p_description text
) RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_receiver_id uuid;
  v_sender_account_id uuid;
  v_receiver_account_id uuid;
  v_transaction_id uuid;
  v_sender_balance decimal;
  v_receiver_balance decimal;
  v_receiver_name text;
  v_sender_name text;
  v_result jsonb;
BEGIN
  -- Verifica se o remetente tem saldo suficiente
  SELECT id, balance INTO v_sender_account_id, v_sender_balance
  FROM accounts
  WHERE user_id = p_sender_id
  FOR UPDATE;
  
  IF v_sender_account_id IS NULL THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Conta do remetente não encontrada'
    );
  END IF;
  
  IF v_sender_balance < p_amount THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Saldo insuficiente'
    );
  END IF;
  
  -- Encontra o destinatário pela chave PIX
  SELECT k.user_id, a.id, a.balance, p.full_name
  INTO v_receiver_id, v_receiver_account_id, v_receiver_balance, v_receiver_name
  FROM pix_keys k
  JOIN accounts a ON a.user_id = k.user_id
  JOIN user_profiles p ON p.id = k.user_id
  WHERE k.key_value = p_pix_key 
    AND k.is_active = true
  FOR UPDATE;
  
  IF v_receiver_id IS NULL THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Chave PIX não encontrada ou inativa'
    );
  END IF;
  
  -- Obtém o nome do remetente
  SELECT full_name INTO v_sender_name
  FROM user_profiles
  WHERE id = p_sender_id;
  
  -- Inicia a transação
  INSERT INTO transactions (
    id, sender_id, receiver_id, amount, type, status, description, created_at, updated_at
  ) VALUES (
    gen_random_uuid(), p_sender_id, v_receiver_id, p_amount, 'PIX', 'PENDING', 
    p_description, now(), now()
  )
  RETURNING id INTO v_transaction_id;
  
  -- Atualiza os saldos
  UPDATE accounts 
  SET balance = balance - p_amount,
      updated_at = now()
  WHERE id = v_sender_account_id;
  
  UPDATE accounts
  SET balance = balance + p_amount,
      updated_at = now()
  WHERE id = v_receiver_account_id;
  
  -- Atualiza o status da transação para concluída
  UPDATE transactions
  SET status = 'COMPLETED',
      updated_at = now()
  WHERE id = v_transaction_id;
  
  -- Retorna o resultado da operação
  RETURN jsonb_build_object(
    'success', true,
    'transaction_id', v_transaction_id,
    'receiver_name', v_receiver_name,
    'amount', p_amount,
    'timestamp', now()
  );
  
EXCEPTION WHEN OTHERS THEN
  -- Em caso de erro, faz rollback da transação
  UPDATE transactions
  SET status = 'FAILED',
      updated_at = now()
  WHERE id = v_transaction_id;
  
  RETURN jsonb_build_object(
    'success', false,
    'message', SQLERRM
  );
END;
$$;
