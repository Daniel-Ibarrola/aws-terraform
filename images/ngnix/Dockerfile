# Use official nginx base image
FROM nginx:alpine

# Copy a simple HTML file to the nginx server
COPY index.html /usr/share/nginx/html/index.html

# Expose port 80
EXPOSE 80

# Command to run nginx (already default in base image)
CMD ["nginx", "-g", "daemon off;"]