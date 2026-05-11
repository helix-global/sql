using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BinaryStudio.SqlServer.Infrastructure;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace BinaryStudio.TestTools.UnitTesting.SqlServer.Infrastructure
    {
    [TestClass]
    public class SqlDateTimeConverterT
        {
        #region T:[SqlDateTimeConverter]:General
        [TestMethod("[SqlDateTimeConverter]:General")]
        public void General() {
            Assert.AreEqual(SqlDateTimeConverter.ConvertFromObject("2012-09-26T17:38:10.797+02:00"),new DateTime(2012,9,26,17,38,10,797,DateTimeKind.Local));
            }
        #endregion
        }
    }
