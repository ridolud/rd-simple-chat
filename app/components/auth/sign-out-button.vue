<script setup lang="ts">
const { auth } = useSupabaseClient();
const loading = ref(false);
const handleLogout = async () => {
  loading.value = true;
  await auth.signOut();
  loading.value = false;

  useRouter().replace("/auth/login");
};
</script>

<template>
  <UButton variant="link" :loading="loading" block @click="handleLogout"
    >Logout</UButton
  >
</template>
