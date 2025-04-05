document.addEventListener('DOMContentLoaded', () => {

  // toggle todo state
  document.querySelectorAll('.toggle-todo').forEach(checkbox => {
    checkbox.addEventListener('change', async (e) => {
      const todoId = e.target.parentElement.dataset.id; // https://developer.mozilla.org/en-US/docs/Web/API/Event/target
      const response = await fetch(`/todos/${todoId}/toggle`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' }
      });
      if (response.ok) { e.target.parentElement.classList.toggle('done'); }
    });
  });

  // delete todo
  document.querySelectorAll('.delete-todo').forEach(button => {
    button.addEventListener('click', async (e) => {
      if (!confirm('Are you sure?')) return;
      const todoId = e.target.parentElement.dataset.id;
      const response = await fetch(`/todos/${todoId}`, {
        method: 'DELETE'
      });
      if (response.ok) { e.target.parentElement.remove(); }
    });
  });

  // save changes to description
  const saveDescription = document.querySelector('.save');
  if (saveDescription) {
    saveDescription.addEventListener('click', async () => { 
      const todoId = window.location.pathname.split('/').pop(); // https://developer.mozilla.org/en-US/docs/Web/API/Location/pathname
      const description = document.querySelector('.edit').value;
      const response = await fetch(`/todos/${todoId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ description })
      });
      if (response.ok) { alert('Description saved!'); }
    });
  }

  // delete comment
  document.querySelectorAll('.delete-comment').forEach(button => {
    button.addEventListener('click', async (e) => {
      if (!confirm('Are you sure?')) return;
      const commentId = e.target.dataset.id;
      const response = await fetch(`/comments/${commentId}`, {
        method: 'DELETE'
      });
      if (response.ok) { e.target.parentElement.remove(); }
    });
  });
});
