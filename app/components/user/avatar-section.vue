<script setup lang="ts">
import type { Database } from "~/types/database";

const user = useSupabaseUser();
const client = useSupabaseClient<Database>();

const { data: user_meta } = useAsyncData(async () => {
  const { data } = await client
    .from("user_metas")
    .select()
    .eq("id", user.value.id)
    .single();

  return data;
});
</script>

<template>
  <div class="flex items-center gap-2">
    <UAvatar size="md" :alt="user_meta?.name" />
    <div>
      <p class="text-sm font-medium">{{ user_meta?.name }}</p>
      <p class="text-xs text-gray-500 italic">{{ user?.email }}</p>
    </div>
  </div>
</template>
