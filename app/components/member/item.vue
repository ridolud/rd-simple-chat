<script setup lang="ts">
import type { Database } from "~/types/database";

const props = defineProps<{ member: any }>();
const emits = defineEmits<{ delete: [user_id: string] }>();
</script>

<template>
  <div class="w-full flex justify-between items-center">
    <p>
      {{ member?.user_metas?.name }}
    </p>
    <UButton
      size="xs"
      variant="link"
      @click="() => emits('delete', member.user_id)"
      icon="i-heroicons-x-mark"
      >Remove</UButton
    >
  </div>
</template>
