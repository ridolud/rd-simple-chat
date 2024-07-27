<script setup lang="ts">
import type { Database } from "~/types/database";

definePageMeta({
  middleware: "auth",
  layout: "chat",
});

const router = useRouter();
const route = useRoute();

const client = useSupabaseClient<Database>();
const { data, status } = useAsyncData(
  async () => {
    const requset = await client
      .from("chats_whit_last_messages")
      .select("*,members:chat_members(user_id)")
      .eq("id", route.params.id as string)
      .single();

    if (requset.error) {
      router.push("/chats");
      return null;
    }

    return requset.data as IChat;
  }
  // { lazy: true }
);
</script>

<template>
  <div v-if="status == 'pending'" class="flex flex-col h-full p-2">
    <USkeleton class="w-full h-12"></USkeleton>
    <div class="flex-1"></div>
    <div class="flex gap-2">
      <USkeleton class="flex-1 h-12"></USkeleton>
      <USkeleton class="flex-none w-10 h-12"></USkeleton>
    </div>
  </div>
  <div v-if="status == 'success' && data" class="flex flex-col h-full">
    <ChatHeader :chat="data" />
    <LazyMessageList />
    <div class="border-t border-gray-800">
      <MessageInput :chat_id="data.id" />
    </div>
  </div>
</template>
