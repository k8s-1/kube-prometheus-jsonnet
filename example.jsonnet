local kp =
  (import 'kube-prometheus/main.libsonnet') +
  // Note that NodePort type services is likely not a good idea for your production use case, it is only used for demonstration purposes here.
  (import 'kube-prometheus/addons/node-ports.libsonnet') +
  {
    values+:: {
      common+: {
        namespace: 'monitoring',
      },
      grafana+: {
        config: {  // http://docs.grafana.org/installation/configuration/
          sections: {
            // Do not require grafana users to login/authenticate
            'auth.anonymous': { enabled: true },
          },
        },
      },
      kubePrometheus+: {
        platform: 'kubeadm',
      },
    },

    // For simplicity, each of the following values for 'externalUrl':
    //  * assume that `minikube ip` prints "192.168.49.2"
    //  * hard-code the NodePort for each app
    prometheus+: {
      prometheus+: {
        // Reference info: https://coreos.com/operators/prometheus/docs/latest/api.html#prometheusspec
        spec+: {
          // An e.g. of the purpose of this is so the "Source" links on http://<alert-manager>/#/alerts are valid.
          externalUrl: 'http://192.168.49.2:30900',
        },
      },
    },
  };

{ ['00namespace-' + name]: kp.kubePrometheus[name] for name in std.objectFields(kp.kubePrometheus) } +
{ ['0prometheus-operator-' + name]: kp.prometheusOperator[name] for name in std.objectFields(kp.prometheusOperator) } +
{ ['node-exporter-' + name]: kp.nodeExporter[name] for name in std.objectFields(kp.nodeExporter) } +
{ ['kube-state-metrics-' + name]: kp.kubeStateMetrics[name] for name in std.objectFields(kp.kubeStateMetrics) } +
{ ['prometheus-' + name]: kp.prometheus[name] for name in std.objectFields(kp.prometheus) } +
{ ['grafana-' + name]: kp.grafana[name] for name in std.objectFields(kp.grafana) }
