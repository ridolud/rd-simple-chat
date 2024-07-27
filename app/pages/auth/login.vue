<script setup lang="ts">
definePageMeta({
  layout: "blank",
  middleware: "guest",
});
</script>

<template>
  <UCard class="w-[380px]">
    <h1 class="text-2xl mb-4">Sign In</h1>
    <AuthSignInForm class="mb-3" />
  </UCard>
</template>
