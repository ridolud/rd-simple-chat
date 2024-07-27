<script setup lang="ts">
import type { IChat } from "~/stores/chats";
import type { Database } from "~/types/database";

const store = useChatsStore();
const { chats } = storeToRefs(store);
const client = useSupabaseClient<Database>();

const { refresh, status } = useAsyncData(async () => {
  const { data } = await client
    .from("chats_whit_last_messages")
    .select("*")
    .order("last_message_created_at", { ascending: true });
  if (data) store.$patch({ chats: data as IChat[] });
  return data;
});
</script>

<template>
  <div class="flex flex-col">
    <div class="flex-1 h-full overflow-y-auto">
      <ChatItem
        v-for="chat in chats"
        :key="chat.id"
        :chat="chat"
        :active="false"
      ></ChatItem>
    </div>
  </div>
</template>
