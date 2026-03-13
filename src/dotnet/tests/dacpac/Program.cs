using System;
using System.Collections.Generic;
using System.Data;
using System.Diagnostics;
using System.IO;
using Aspose.Zip.Saving;
using Aspose.Zip.SevenZip;
using BinaryStudio.SqlServer.Infrastructure;
using BinaryStudio.SqlServer.Infrastructure.A2C;
using BinaryStudio.SqlServer.Infrastructure.DAC;
//using SharpCompress.Archives.SevenZip;
using SharpSevenZipArchive=SharpCompress.Archives.SevenZip.SevenZipArchive;

namespace dacpac
    {
    internal class Program
        {
        #region M:RebuildA2CX(String)
        private static void RebuildA2CX(String filename) {
            var ds = new DataSet();
            using (var stream = File.OpenRead(filename)) {
                using (var archive = SharpSevenZipArchive.OpenArchive(stream)) {
                    foreach (var entry in archive.Entries) {
                        if (!entry.IsDirectory) {
                            ds.ReadXml(entry.OpenEntryStream());
                            break;
                            }
                        }
                    }
                }
            var table = ds.Tables["DEF_ASSEMBLY_FILES"];
            while (table.Rows.Count > 1) {
                var row = table.Rows[0];
                if (!String.Equals("A2Core.dll",row["FILENAME"].ToString(),StringComparison.OrdinalIgnoreCase)) {
                    table.Rows.RemoveAt(0);
                    }
                }
            using (var stream = File.Open(Path.ChangeExtension(filename,".xml"), FileMode.Create)) {
                ds.WriteXml(stream);
                }
            //var e = new MemoryStream();
            //using (var stream = File.Open(filename+"x", FileMode.Create)) {
            //    using (var archive = new SevenZipArchive(new SevenZipEntrySettings(new SevenZipLZMA2CompressionSettings()))) {
            //        archive.CreateEntry(Path.GetFileNameWithoutExtension(filename),e,new SevenZipEntrySettings(new SevenZipStoreCompressionSettings()));
            //        archive.Save(stream);
            //        }
            //    }
            return;
            }
        #endregion

        private static void Main(String[] args) {
            //var maxN = 0;
            //foreach (SqlPermission i in Enum.GetValues(typeof(SqlPermission))) {
            //    maxN = Math.Max(maxN,i.ToString().Length);
            //    }
            //foreach (SqlPermission i in Enum.GetValues(typeof(SqlPermission))) {
            //    Debug.WriteLine(String.Format($"{{0,-{maxN}}} = 0x{{1:x4}},", i,(Int32)i));
            //    }
            //var r = DataSchemaModel.LoadFrom("dev.xml");
            try
                {
                //RebuildA2CX("2022.07.05.0847.a2cx");
                var r = A2CPackage.LoadFrom("2026.03.02.1553.7z");
                }
            catch (Exception e)
                {
                Debug.WriteLine(Exceptions.Format(e));
                throw;
                }
            
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
