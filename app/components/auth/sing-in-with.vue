<script setup lang="ts">
const { auth } = useSupabaseClient();

const handleSignInWithGoogle = async () => {
  const { error } = await auth.signInWithOAuth({
    provider: "google",
  });

  if (error)
    useToast().add({
      color: "red",
      title: "Bad Requset",
      description: error.message,
    });
};
</script>

<template>
  <UButton @click="handleSignInWithGoogle" color="black" variant="outline" block
    >Google</UButton
  >
</template>
