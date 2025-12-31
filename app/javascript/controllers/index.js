// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

// Explicitly import and register the file_preview controller to satisfy static analyzers
import FilePreviewController from "./file_preview_controller"
application.register("file-preview", FilePreviewController)

eagerLoadControllersFrom("controllers", application)
