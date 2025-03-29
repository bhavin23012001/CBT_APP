import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  vus: 50, // 50 virtual users
  duration: '30s', // Run test for 30 seconds
};

export default function () {
  let res = http.get('https://your-api-endpoint.com'); // Replace with your API URL
  check(res, {
    'Status is 200': (r) => r.status === 200,
    'Response time < 500ms': (r) => r.timings.duration < 500,
  });
  sleep(1);
}
