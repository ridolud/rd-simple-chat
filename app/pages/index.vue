<script setup lang="ts">
definePageMeta({
  layout: "blank",
});

const user = useSupabaseUser();
</script>

<template>
  <div class="container text-center">
    <h1 class="text-8xl font-medium mb-4 font-serif">
      <span class="text-primary">Simple</span> <br />
      Chat App
    </h1>
    <p class="mb-8">
      Welcome to the Simple Chat App! Connect with friends and start chatting.
    </p>
    <div v-if="!user" class="space-x-2">
      <UButton color="black" variant="outline" to="/auth/login"
        >Sign In</UButton
      >
      <UButton to="/auth/register">Register</UButton>
    </div>
    <div v-if="user" class="space-x-2">
      <UButton size="lg" to="/chats">Start Chating</UButton>
    </div>
  </div>
</template>
