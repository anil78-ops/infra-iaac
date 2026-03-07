# --------------------------------------------------------------------------------------------------
# VPC
# --------------------------------------------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    {
      Name    = "${var.project_name}"
      env     = var.environment,
      tenant  = var.tenant,
      project = var.project,
      app     = "${var.project_name}-${var.app}",
      team    = var.team
    }
  )
}

# --------------------------------------------------------------------------------------------------
# INTERNET GATEWAY
# --------------------------------------------------------------------------------------------------
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      "Name" = lower("${var.project_name}-igw")
    },
    {
      "env"     = lower(var.environment),
      "tenant"  = lower(var.tenant),
      "project" = lower(var.project),
      "app"     = lower("${var.project_name}-${var.app}"),
      "team"    = lower(var.team),
      "zone"    = "public"
    }
  )
}

# --------------------------------------------------------------------------------------------------
# PUBLIC SUBNETS, ROUTE TABLE, AND ASSOCIATIONS
# --------------------------------------------------------------------------------------------------
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    {
      "Name" = lower("${var.project_name}-public-subnet-${var.availability_zones[count.index]}")
    },
    {
      "env"     = lower(var.environment),
      "tenant"  = lower(var.tenant),
      "project" = lower(var.project),
      "app"     = lower("${var.project_name}-${var.app}"),
      "team"    = lower(var.team),
      "zone"    = "public"
    },
    var.eks_cluster_name != "" ? {
      "eks_cluster_name"                              = var.eks_cluster_name,
      "kubernetes.io/role/elb"                        = "1"
      "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    } : {}
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    {
      "Name" = lower("${var.project_name}-public-rt")
    },
    {
      "env"     = lower(var.environment),
      "tenant"  = lower(var.tenant),
      "project" = lower(var.project),
      "app"     = lower("${var.project_name}-${var.app}"),
      "team"    = lower(var.team),
      "zone"    = "public"
    }
  )
  lifecycle {
    ignore_changes = [route]
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# --------------------------------------------------------------------------------------------------
# NAT GATEWAYS AND ELASTIC IPS
# --------------------------------------------------------------------------------------------------
resource "aws_eip" "nat" {
  count = length(var.availability_zones)
  domain = "vpc"

  tags = merge(
    {
      "Name" = lower("${var.project_name}-nat-eip-${var.availability_zones[count.index]}")
    },
    {
      "env"     = lower(var.environment),
      "tenant"  = lower(var.tenant),
      "project" = lower(var.project),
      "app"     = lower("${var.project_name}-${var.app}"),
      "team"    = lower(var.team),
      "zone"    = "public"
    }
  )
}

resource "aws_nat_gateway" "main" {
  count         = length(var.availability_zones)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = element(aws_subnet.public.*.id, count.index)

  tags = merge(
    {
      "Name" = lower("${var.project_name}-nat-gw-${var.availability_zones[count.index]}")
    },
    {
      "env"     = lower(var.environment),
      "tenant"  = lower(var.tenant),
      "project" = lower(var.project),
      "app"     = lower("${var.project_name}-${var.app}"),
      "team"    = lower(var.team),
      "zone"    = "public"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# --------------------------------------------------------------------------------------------------
# PRIVATE SUBNETS, ROUTE TABLES, AND ASSOCIATIONS
# --------------------------------------------------------------------------------------------------
resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    {
      "Name" = lower("${var.project_name}-private-subnet-${var.availability_zones[count.index]}")
    },
    {
      "env"     = lower(var.environment),
      "tenant"  = lower(var.tenant),
      "project" = lower(var.project),
      "app"     = lower("${var.project_name}-${var.app}"),
      "team"    = lower(var.team),
      "zone"    = "private"
    },
    var.eks_cluster_name != "" ? {
      "eks_cluster_name"                              = var.eks_cluster_name,
      "kubernetes.io/role/internal-elb"               = "1"
      "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    } : {}
  )
}

resource "aws_route_table" "private" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = merge(
    {
      "Name" = lower("${var.project_name}-private-rt-${var.availability_zones[count.index]}")
    },
    {
      "env"     = lower(var.environment),
      "tenant"  = lower(var.tenant),
      "project" = lower(var.project),
      "app"     = lower("${var.project_name}-${var.app}"),
      "team"    = lower(var.team),
      "zone"    = "private"
    }
  )
  lifecycle {
    ignore_changes = [route]
  }
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[index(var.availability_zones, aws_subnet.private[count.index].availability_zone)].id
}