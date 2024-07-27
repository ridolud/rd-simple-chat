<script setup lang="ts">
import type { Database } from "~/types/database";

const props = defineProps<{ chat_id: string }>();
const emits = defineEmits(["close"]);

const client = useSupabaseClient<Database>();
const user = useSupabaseUser();
const {
  data: members,
  status,
  refresh,
} = useAsyncData(async () => {
  const { data, error } = await client
    .from("chat_members")
    .select(
      `
      user_id,
      chat_id,
      user_metas (
        name
      )
    `
    )
    .eq("chat_id", props.chat_id)
    .neq("user_id", user.value.id);
  return data;
});

async function handleDelete(user_id: string) {
  await client
    .from("chat_members")
    .delete()
    .eq("chat_id", props.chat_id)
    .eq("user_id", user_id);

  refresh();
}
</script>

<template>
  <UModal>
    <UCard>
      <template #header>
        <div class="flex w-full justify-between">
          <h1>Chat members</h1>
          <UButton
            :padded="false"
            color="gray"
            variant="link"
            @click.stop="() => emits('close')"
            icon="i-heroicons-x-mark"
          />
        </div>
      </template>
      <MemberInviteForm @success="refresh" class="mb-3" :chat_id="chat_id" />
      <div class="max-h-[400px] overflow-y-scroll space-y-2">
        <MemberItem
          :member="member"
          v-for="member in members"
          :key="member.user_id"
          @delete="handleDelete"
        />
      </div>
      <div v-if="status == 'pending'">
        <USkeleton class="w-full h-6"></USkeleton>
        <USkeleton class="w-full h-6"></USkeleton>
      </div>
    </UCard>
  </UModal>
</template>
