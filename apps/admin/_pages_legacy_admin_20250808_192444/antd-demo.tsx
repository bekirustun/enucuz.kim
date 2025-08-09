import { Button, DatePicker, ConfigProvider } from "antd";
import trTR from "antd/locale/tr_TR";
import dayjs from "dayjs";
import "dayjs/locale/tr";
dayjs.locale("tr");

export default function AntdDemo() {
  return (
    <ConfigProvider locale={trTR}>
      <div style={{ padding: 24 }}>
        <Button type="primary">Merhaba Antd</Button>
        <span style={{ marginLeft: 12 }} />
        <DatePicker />
      </div>
    </ConfigProvider>
  );
}
