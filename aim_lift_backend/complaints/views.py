from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required
from .models import Complaint

@login_required
def complaint_dashboard(request):
    role = request.user.role
    complaints = Complaint.objects.all().order_by("-created_at")

    if request.method == "POST":
        if role == "CLIENT":
            # Client files a new complaint
            title = request.POST.get("title")
            desc = request.POST.get("description")

            if title and desc:
                Complaint.objects.create(
                    title=title,
                    description=desc,
                    created_by=request.user
                )
            return redirect("complaints")

        elif role in ["JKR", "CONTRACTOR"]:
            # JKR/Contractor updates status
            complaint_id = request.POST.get("complaint_id")
            status = request.POST.get("status")

            if complaint_id and status:
                complaint = get_object_or_404(Complaint, id=complaint_id)
                complaint.status = status
                complaint.save()
            return redirect("complaints")

    return render(request, "complaints/complaints.html", {
        "complaints": complaints,
        "role": role
    })
