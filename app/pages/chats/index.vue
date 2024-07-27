<script setup lang="ts">
import { ChatNewChannelModal } from "#components";

definePageMeta({
  middleware: "auth",
  layout: "chat",
});

const newChannelModal = useModal();
function handleOpenNewChannelModal() {
  newChannelModal.open(ChatNewChannelModal, {
    onClose() {
      newChannelModal.close();
    },
  });
}
</script>

<template>
  <div class="flex justify-center items-center h-full">
    <div class="text-center">
      <h1 class="text-xl text-primary mb-2">Simple Chat App</h1>
      <UButton color="black" variant="link" @click="handleOpenNewChannelModal"
        >Start New Chat</UButton
      >
    </div>
  </div>
</template>
