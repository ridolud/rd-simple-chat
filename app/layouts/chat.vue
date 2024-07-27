<script setup lang="ts">
import type { RealtimeChannel } from "@supabase/supabase-js";
import type { IMessage } from "~/stores/messages";
import type { Database } from "~/types/database";

const route = useRoute();
const user = useSupabaseUser();
const messageStore = useMessagesStore();
const chatStore = useChatsStore();
const client = useSupabaseClient<Database>();
const chat_id = route.name == "chats-id" ? route.params.id : undefined;
const onlineMembers = useState<string[]>("online-members", () => []);
let realtimeChannel: RealtimeChannel;

async function handleLoadMessage(messageId: string) {
  const { data: message } = await client
    .from("messages")
    .select("*, user_metas(id, name)")
    .eq("id", messageId)
    .single();

  if (!message) return;
  if (!chat_id && chat_id != message.chat_id) return;

  messageStore.addMessage(message as IMessage);
}

onMounted(() => {
  realtimeChannel = client.channel("public:messages");
  realtimeChannel.on(
    "postgres_changes",
    {
      event: "INSERT",
      schema: "public",
      table: "messages",
      filter: `user_id=neq.${user.value.id}`,
    },
    (payload: any) => handleLoadMessage(payload.new.id)
  );

  realtimeChannel.on("presence", { event: "sync" }, () => {
    const userIds = [];
    for (const id in realtimeChannel.presenceState()) {
      // @ts-ignore
      userIds.push(realtimeChannel.presenceState()[id][0].user_id);
    }
    onlineMembers.value = [...new Set(userIds)];
  });

  realtimeChannel.subscribe((status) => {
    if (status == "SUBSCRIBED") {
      realtimeChannel.track({
        online_at: new Date().toISOString(),
        user_id: user.value.id,
      });
    }
  });
});

onUnmounted(() => {
  realtimeChannel.unsubscribe();
});
</script>

<template>
  <div class="h-screen flex container overflow-hidden mx-auto p-6">
    <div class="md:w-1/4 border border-gray-800">
      <div
        class="flex justify-between items-center pl-4 h-16 border-b border-gray-800"
      >
        <UserAvatarSection />
        <ActionsMenu />
      </div>
      <ChatList />
    </div>
    <div class="md:w-3/4 border-l-0 border border-gray-800">
      <slot />
    </div>
  </div>
</template>
