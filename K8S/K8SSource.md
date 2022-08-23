# K8SSource



* kube-apiserver进程的入口: github/com/GoogleCloudPlatform/kubernetes/cmd/kube-apiserver/apiserver.go,入口main()

  ```go
  func main() {
      runtime.GOMAXPROCS(runtime.NumCPU())
      rand.Seed(time.Now().UTC().UnixNano())
      s := app.NewAPIServer()
      s.AddFlags(pflag.CommandLine)
      util.InitFlags()
      util.InitLogs()
      defer util.FlushLogs()
      verflag.PrintAndExitIfRequested()
      if err := s.Run(pflag.CommandLine.Args()); err != nil {
          fmt.Fprintf(os.Stderr, ＂ %v\n＂ , err)
          os.Exit(1)
      }
  }
  ```

  