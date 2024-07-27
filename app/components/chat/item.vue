<script setup lang="ts">
import type { IChat } from "~/stores/chats";

const props = defineProps<{ chat: IChat }>();
</script>

<template>
  <NuxtLink
    class="relative pl-3 flex gap-4 flex-row items-center cursor-pointer hover:bg-gray-800/50"
    :to="`/chats/${chat.id}`"
    active-class="chat-selected"
  >
    <div class="">
      <UAvatar size="md" :alt="chat.name" />
    </div>
    <div class="mr-3 basis-auto min-w-0 w-full border-b border-gray-800 py-4">
      <div class="flex items-center justify-between">
        <p class="truncate flex-1">{{ chat.name }}</p>
        <p class="text-xs text-gray-500">
          {{
            chat?.last_message_created_at
              ? toFormatRelative(chat.last_message_created_at)
              : ""
          }}
        </p>
      </div>
      <div class="flex h-4 flex-row text-gray-500 gap-2 mt-1 text-sm">
        <p class="truncate basis-auto w-full">
          <span v-if="chat.last_message_message"
            >{{ chat?.last_message_user_name }}
            {{ chat?.last_message_message }}</span
          >
          <span v-else class="text-gray-600 text-xs italic"
            >No message yet</span
          >
        </p>
      </div>
    </div>
  </NuxtLink>
</template>

<style scoped>
.chat-selected {
  background-color: rgb(var(--color-gray-800));
}
</style>
