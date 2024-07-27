<script setup lang="ts">
import { MemberListModal } from "#components";
import type { Database } from "~/types/database";

const client = useSupabaseClient<Database>();
const user = useSupabaseUser();
const chatStore = useChatsStore();
const loading = useLoadingIndicator();
const router = useRouter();
const props = defineProps<{ chat: IChat }>();

// Invite new member modal
const inviteMemberModal = useModal();
function handleOpenMembersModal() {
  inviteMemberModal.open(MemberListModal, {
    chat_id: props.chat.id,
    onClose() {
      inviteMemberModal.close();
    },
  });
}

// Delete chat
async function handleDeleteChat() {
  loading.start();
  const { error } = await client.from("chats").delete().eq("id", props.chat.id);
  loading.finish();

  if (error) {
    const errorMessage =
      error.code == "23505" ? "Member already exist" : error.message;
    useToast().add({
      color: "red",
      title: "Can't delete chat!",
      description: errorMessage,
    });
  } else {
    chatStore.removeChat(props.chat.id);
    router.replace("/chats");
  }
}

// Leave Chat
async function handleLeaveChat() {
  loading.start();
  const { error } = await client
    .from("chat_members")
    .delete()
    .eq("chat_id", props.chat.id)
    .eq("user_id", user.value.id);
  loading.finish();

  if (error) {
    useToast().add({
      color: "red",
      title: "Can't leave chat!",
      description: error.message,
    });
  } else {
    chatStore.removeChat(props.chat.id);
    router.replace("/chats");
  }
}

const isOwner = computed<boolean>(() => user.value.id == props.chat.owner_id);
const menus = computed(() => {
  return isOwner.value
    ? [
        [
          {
            label: "Chat Members",
            icon: "i-heroicons-user-plus",
            click: () => handleOpenMembersModal(),
          },
        ],
        [
          {
            label: "Delete Chat",
            icon: "i-heroicons-trash",
            click: () => {
              useToast().add({
                color: "red",
                title: "Are you sure to delete chat?",
                actions: [
                  {
                    label: "Confirm",
                    click: () => handleDeleteChat(),
                  },
                ],
              });
            },
          },
        ],
      ]
    : [
        [
          {
            label: "Leave Chat",
            icon: "i-heroicons-arrow-right-on-rectangle",
            click: () => {
              useToast().add({
                color: "red",
                title: "Are you sure to leave chat?",
                actions: [
                  {
                    label: "Confirm",
                    click: () => handleLeaveChat(),
                  },
                ],
              });
            },
          },
        ],
      ];
});
</script>

<template>
  <div
    class="flex justify-between pl-4 items-center min-h-16 border-b border-gray-800"
  >
    <div class="flex gap-2 items-center">
      <UAvatar size="md" :alt="chat.name"></UAvatar>
      <p>{{ chat.name }}</p>
      <MemberPresence :members="chat.members" />
    </div>
    <div class="flex items-center">
      <UDropdown :items="menus" :popper="{ placement: 'bottom-end' }">
        <UButton
          size="xl"
          color="gray"
          variant="link"
          icon="i-heroicons-ellipsis-vertical"
        ></UButton>
        <template #item="{ item }">
          <span class="truncate">{{ item.label }}</span>
          <UIcon :name="item.icon" class="flex-shrink-0 h-4 w-4 ms-auto" />
        </template>
      </UDropdown>
    </div>
  </div>
</template>
