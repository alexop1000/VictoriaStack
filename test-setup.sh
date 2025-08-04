#!/bin/bash

# Test setup script for VictoriaStack
# This script helps you start and manage the test environment

set -e

echo "🚀 VictoriaStack Test Setup"
echo "=========================="

# Function to check if services are healthy
check_services() {
    echo "🔍 Checking service health..."
    
    # Check VictoriaMetrics
    if curl -s http://localhost:8428/health > /dev/null; then
        echo "✅ VictoriaMetrics is healthy"
    else
        echo "❌ VictoriaMetrics is not responding"
        return 1
    fi
    
    # Check VictoriaLogs
    if curl -s http://localhost:9428/health > /dev/null; then
        echo "✅ VictoriaLogs is healthy"
    else
        echo "❌ VictoriaLogs is not responding"
        return 1
    fi
    
    # Check Grafana
    if curl -s http://localhost:3000/api/health > /dev/null; then
        echo "✅ Grafana is healthy"
    else
        echo "❌ Grafana is not responding"
        return 1
    fi
}

# Function to start the test environment
start_test() {
    echo "🔧 Starting VictoriaStack with test data generators..."
    
    # Start the main services first
    docker-compose up -d
    
    echo "⏳ Waiting for services to be ready..."
    sleep 30
    
    # Check if services are healthy
    if check_services; then
        echo "🧪 Starting test data generators..."
        # Start test services
        docker-compose -f docker-compose.yml -f docker-compose.test.yml up -d
        
        echo ""
        echo "🎉 Test environment is ready!"
        echo ""
        echo "📊 Access your services:"
        echo "   • Grafana: http://localhost:3000 (admin/admin)"
        echo "   • VictoriaMetrics: http://localhost:8428"
        echo "   • VictoriaLogs: http://localhost:9428"
        echo ""
        echo "📈 Test data is being generated automatically:"
        echo "   • Metrics: CPU, memory, HTTP requests, response times"
        echo "   • Logs: Application logs, access logs, error logs"
        echo ""
        echo "To stop the test environment, run: ./test-setup.sh stop"
    else
        echo "❌ Services are not healthy. Please check the logs."
        exit 1
    fi
}

# Function to stop the test environment
stop_test() {
    echo "🛑 Stopping test environment..."
    docker-compose -f docker-compose.yml -f docker-compose.test.yml down
    echo "✅ Test environment stopped"
}

# Function to view logs
view_logs() {
    echo "📋 Viewing logs for all services..."
    docker-compose -f docker-compose.yml -f docker-compose.test.yml logs -f
}

# Function to restart test generators
restart_generators() {
    echo "🔄 Restarting test data generators..."
    docker-compose -f docker-compose.yml -f docker-compose.test.yml restart metrics-generator logs-generator
    echo "✅ Test generators restarted"
}

# Function to show status
show_status() {
    echo "📊 Service Status:"
    docker-compose -f docker-compose.yml -f docker-compose.test.yml ps
    echo ""
    check_services 2>/dev/null || echo "⚠️  Some services may not be ready yet"
}

# Main script logic
case "${1:-start}" in
    "start")
        start_test
        ;;
    "stop")
        stop_test
        ;;
    "restart")
        stop_test
        sleep 5
        start_test
        ;;
    "logs")
        view_logs
        ;;
    "status")
        show_status
        ;;
    "restart-generators")
        restart_generators
        ;;
    "help"|"-h"|"--help")
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  start              Start the test environment (default)"
        echo "  stop               Stop the test environment"
        echo "  restart            Restart the test environment"
        echo "  logs               View logs from all services"
        echo "  status             Show service status"
        echo "  restart-generators Restart only the test data generators"
        echo "  help               Show this help message"
        ;;
    *)
        echo "❌ Unknown command: $1"
        echo "Run '$0 help' for usage information"
        exit 1
        ;;
esac