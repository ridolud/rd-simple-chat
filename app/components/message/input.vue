<script setup lang="ts">
import { v4 as uuidv4 } from "uuid";
import type { IMessage } from "~/stores/messages";

const props = defineProps<{ chat_id: string }>();

const client = useSupabaseClient();
const user = useSupabaseUser();
const store = useMessagesStore();

const textMessage = ref("");

async function onSentMessage(message: any) {
  const { data, error } = await client
    .from("messages")
    // @ts-ignore
    .insert([message])
    .select()
    .single();
}

function handleSentMessage() {
  if (!textMessage) return;

  const id = uuidv4();
  const newMessage: IMessage = {
    id,
    message: textMessage.value,
    user_id: user.value.id,
    chat_id: props.chat_id,
    created_at: new Date().toISOString(),
  };
  store.addMessage(newMessage);

  textMessage.value = "";

  onSentMessage(newMessage);
}
</script>

<template>
  <div class="w-full flex items-end">
    <UTextarea
      size="lg"
      class="w-full p-3"
      variant="none"
      :rows="1"
      :maxrows="4"
      autoresize
      placeholder="Type Here.."
      v-model="textMessage"
    ></UTextarea>
    <UButton
      variant="link"
      size="xl"
      color="gray"
      icon="i-heroicons-chevron-right"
      class="mb-3"
      @click="handleSentMessage"
    ></UButton>
  </div>
</template>
