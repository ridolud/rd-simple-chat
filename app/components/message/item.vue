<script setup lang="ts">
const props = defineProps<{ message: any }>();

const user = useSupabaseUser();
const isMe = computed(() => user.value.id == props.message.user_id);
</script>

<template>
  <div class="chat-message" :class="{ send: isMe }">
    <div class="chat-message-item w-full flex flex-col mb-2 px-4">
      <div class="wrapper flex flex-rowl max-w-[60%] gap-3">
        <div v-if="!isMe">
          <UAvatar alt="asdasd" />
        </div>
        <div
          class="message relative rounded py-2 px-3 min-w-[200px] bg-gray-800"
        >
          <p v-if="!isMe" class="text-sm text-primary font-medium">
            {{ message?.user_metas?.name }}
          </p>
          <p class="text-sm mt-1 whitespace-pre-wrap">
            {{ message.message }}
          </p>
          <p class="text-right text-xs text-gray-500">
            {{ toFormatRelative(message.created_at) }}
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.chat-message.send .chat-message-item {
  align-items: end;
}
.chat-message.send .chat-message-item .wrapper {
  flex-direction: row-reverse;
}
.chat-message .chat-message-item .message::before {
  content: "";
  position: absolute;
  border-top: 20px solid rgb(var(--color-gray-800));
  border-radius: 4px;
  border-left: 20px solid transparent;
  width: 0;
  height: 0;
  left: -12px;
  top: 0px;
}
.chat-message.send .chat-message-item .message::before {
  left: auto;
  right: -12px;
  border-right: 20px solid transparent;
  border-left: none;
}
</style>
