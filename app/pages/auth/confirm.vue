<script setup lang="ts">
const user = useSupabaseUser();

definePageMeta({
  layout: "blank",
});

watch(
  user,
  () => {
    if (user.value) {
      return navigateTo("/");
    }
  },
  { immediate: true }
);
</script>

<template>
  <div>
    <p class="u-text-black">Redirecting...</p>
  </div>
</template>
