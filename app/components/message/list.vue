<script setup lang="ts">
import type { Database } from "~/types/database";

const client = useSupabaseClient<Database>();
const route = useRoute();
const store = useMessagesStore();
const { messages } = storeToRefs(store);
const loading = ref(false);
const hasMore = ref(true);
const page = ref(0);

async function handleFetchMessages() {
  loading.value = true;

  const curentPage = getFromAndTo(page.value, 12);
  const { data, count } = await client
    .from("messages")
    .select(`*, user_metas(id, name)`, { count: "exact" })
    .eq("chat_id", route.params.id as string)
    .order("created_at", { ascending: false })
    .range(curentPage.from, curentPage.to);

  loading.value = false;

  store.$patch({
    messages: [...store.$state.messages, ...(data as IMessage[])],
  });

  if (count && store.$state.messages.length >= count) hasMore.value = false;
}

onMounted(async () => {
  store.$patch({ messages: [] });
  handleFetchMessages();
});

const containerScrollProps = ref();
const handleNextPage = useDebounceFn(async () => {
  page.value += 1;
  await handleFetchMessages();
}, 400);

useInfiniteScroll(
  containerScrollProps,
  () => {
    handleNextPage();
  },
  {
    direction: "top",
    interval: 400,
    canLoadMore: () => !loading.value && hasMore.value,
  }
);
</script>

<template>
  <div
    ref="containerScrollProps"
    class="grow overflow-y-auto flex flex-col-reverse py-2"
  >
    <MessageItem
      v-for="message in messages"
      :key="message.id"
      :message="message"
    />
    <div v-if="loading" class="flex flex-col items-center gap-2 px-3 mb-4">
      <USkeleton class="h-4 w-2/3" />
      <USkeleton class="h-4 w-1/3" />
    </div>
    <div class="text-center mb-4" v-if="!loading && !messages.length">
      <span class="text-gray-600 text-xs">No message yet</span>
    </div>
    <div class="text-center mb-4" v-if="!loading && !hasMore">
      <span class="text-gray-600 text-xs">There's the oldest message</span>
    </div>
  </div>
</template>
