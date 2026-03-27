using System;
using System.Reflection;
using System.Xml;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal static class XmlWriterSettingsExtensions
        {
        #region M:ReadOnly({this}XmlWriterSettings):Boolean
        public static Boolean ReadOnly(this XmlWriterSettings settings) {
            var r = settings.GetType().GetProperty("ReadOnly", BindingFlags.Instance | BindingFlags.NonPublic)?.GetValue(settings);
            return (r != null)
                ? (Boolean)r
                : false;
            }
        #endregion
        #region M:ReadOnly({this}XmlWriterSettings,Boolean)
        public static void ReadOnly(this XmlWriterSettings settings, Boolean value) {
            var pi = settings.GetType().GetProperty("ReadOnly", BindingFlags.Instance | BindingFlags.NonPublic);
            if (pi != null) {
                pi.SetValue(settings, value);
                }
            }
        #endregion
        #region M:Standalone({this}XmlWriterSettings):XmlStandalone
        public static XmlStandalone Standalone(this XmlWriterSettings settings) {
            var r = settings.GetType().GetProperty("Standalone", BindingFlags.Instance | BindingFlags.NonPublic)?.GetValue(settings);
            return (r != null)
                ? (XmlStandalone)(Int32)r
                : XmlStandalone.No;
            }
        #endregion
        #region M:Standalone({this}XmlWriterSettings,XmlStandalone)
        internal static void Standalone(this XmlWriterSettings settings,XmlStandalone value) {
            var pi = settings.GetType().GetProperty("Standalone", BindingFlags.Instance | BindingFlags.NonPublic);
            if (pi != null) {
                pi.SetValue(settings,(Int32)value);
                }
            }
        #endregion
        #region M:AutoXmlDeclaration({this}XmlWriterSettings):Boolean
        public static Boolean AutoXmlDeclaration(this XmlWriterSettings settings) {
            var r = settings.GetType().GetProperty("AutoXmlDeclaration", BindingFlags.Instance | BindingFlags.NonPublic)?.GetValue(settings);
            return (r != null)
                ? (Boolean)r
                : false;
            }
        #endregion
        #region M:AutoXmlDeclaration({this}XmlWriterSettings,Boolean)
        public static void AutoXmlDeclaration(this XmlWriterSettings settings, Boolean value) {
            var pi = settings.GetType().GetProperty("AutoXmlDeclaration", BindingFlags.Instance | BindingFlags.NonPublic);
            if (pi != null) {
                pi.SetValue(settings, value);
                }
            }
        #endregion
        #region M:MergeCDataSections({this}XmlWriterSettings):Boolean
        public static Boolean MergeCDataSections(this XmlWriterSettings settings) {
            var r = settings.GetType().GetProperty("MergeCDataSections", BindingFlags.Instance | BindingFlags.NonPublic)?.GetValue(settings);
            return (r != null)
                ? (Boolean)r
                : false;
            }
        #endregion
        #region M:OutputMethod({this}XmlWriterSettings,XmlOutputMethod)
        internal static void OutputMethod(this XmlWriterSettings settings, XmlOutputMethod value) {
            var pi = settings.GetType().GetProperty("OutputMethod", BindingFlags.Instance | BindingFlags.NonPublic);
            if (pi != null) {
                pi.SetValue(settings, value);
                }
            }
        #endregion
        }
    }