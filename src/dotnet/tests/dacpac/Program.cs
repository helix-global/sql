using BinaryStudio.SqlServer.Infrastructure;
using BinaryStudio.SqlServer.Infrastructure.DAC;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Runtime.InteropServices;
using BinaryStudio.SqlServer.Infrastructure.A2C;

namespace dacpac
    {
    internal class Program
        {
        private static void Main(String[] args) {
            //var maxN = 0;
            //foreach (SqlPermission i in Enum.GetValues(typeof(SqlPermission))) {
            //    maxN = Math.Max(maxN,i.ToString().Length);
            //    }
            //foreach (SqlPermission i in Enum.GetValues(typeof(SqlPermission))) {
            //    Debug.WriteLine(String.Format($"{{0,-{maxN}}} = 0x{{1:x4}},", i,(Int32)i));
            //    }
            //var r = DataSchemaModel.LoadFrom("dev.xml");
            var r = A2CPackage.LoadFrom("2022.07.05.0847.a2cx");
            //var r = A2CPackage.LoadFrom("2026.03.02.1623.a2c");
            //try
            //    {
            //    F3();
            //    }
            //catch (Exception e)
            //    {
            //    Debug.WriteLine(Exceptions.Format(e));
            //    }
            //try
            //    {
            //    F5();
            //    }
            //catch (Exception e)
            //    {
            //    Debug.WriteLine(Exceptions.Format(e));
            //    }
            return;
            }
        #region M:F1
        private static void F1()
            {
            try
                {
                throw new InvalidOperationException();
                }
            catch (Exception e)
                {
                e.Data["Context1"] = "Context1";
                throw new Exception($"F1-{e.Message}",e);
                }
            }
        #endregion
        #region M:F2
        private static void F2()
            {
            try
                {
                F1();
                }
            catch (Exception e)
                {
                e.Data["Context2"] = "Context2";
                throw new Exception($"F2-{e.Message}",e);
                }
            }
        #endregion
        #region M:F3
        private static void F3()
            {
            try
                {
                F2();
                }
            catch (Exception e)
                {
                e.Data["Context3"] = "Context3";
                throw new Exception($"F3-{e.Message}",e);
                }
            }
        #endregion
        #region M:F4
        private static void F4()
            {
            try
                {
                F3();
                }
            catch (Exception e)
                {
                e.Data["Context4"] = "Context4";
                throw new Exception($"F4-{e.Message}",e);
                }
            }
        #endregion
        #region M:F5
        private static void F5()
            {
            try
                {
                var exceptions = new List<Exception>();
                try
                    {
                    F3();
                    }
                catch (Exception e)
                    {
                    exceptions.Add(e);
                    }
                try
                    {
                    F4();
                    }
                catch (Exception e)
                    {
                    exceptions.Add(e);
                    }
                try
                    {
                    F4();
                    }
                catch (Exception e)
                    {
                    exceptions.Add(e);
                    }
                try
                    {
                    F4();
                    }
                catch (Exception e)
                    {
                    exceptions.Add(e);
                    }
                try
                    {
                    F4();
                    }
                catch (Exception e)
                    {
                    exceptions.Add(e);
                    }
                throw new AggregateException("Multiple exceptions", exceptions);
                }
            catch (Exception e)
                {
                e.Data["Context5"] = "Context5";
                throw new Exception($"F5-{e.Message}",e);
                }
            }
        #endregion
        }
    }
